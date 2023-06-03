import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webrtc/receiveCall.dart';
import 'Signaling.dart';
import 'api.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'app_router.dart';
import 'callPage.dart';
import 'navigation_service.dart';

late PackageInfoData packageInfo;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initialize();
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: 'notification',
        channelName: 'notification',
        channelDescription: "hello world",
        defaultColor: Colors.red,
        playSound: true,
        enableVibration: true)
  ]);
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: AppRoute.generateRoute,
      initialRoute: AppRoute.homePage,
      navigatorKey: NavigationService.instance.navigationKey,
      navigatorObservers: <NavigatorObserver>[
        NavigationService.instance.routeObserver
      ],

    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String? _currentUuid;

  TextEditingController textEditingController = TextEditingController(text: '');
  TextEditingController textEditingController2 =
      TextEditingController(text: '');
  var deviceToken;
  bool show = true;

  @override
  void initState() {
    FirebaseMessaging? _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((token) {
      deviceToken = token;
      print("token is $deviceToken");
    });
    WidgetsBinding.instance.addObserver(this);


    super.initState();
    checkAndNavigationCallingPage();

    FirebaseMessaging.onMessage.listen((event) {
      myBackgroundMessageHandler(event);
    });

    /* AwesomeNotifications().actionStream.listen((event) {
      if (event.buttonKeyPressed.isNotEmpty) {
        print("join join1${event.buttonKeyPressed}");
          setValue(TOKEN, event.buttonKeyPressed);
        setValue(USER_NAME, event.title);
        Navigator.pushNamed(context, '/second');

        print("join join2");
      } else if (event.buttonKeyPressed == "decline") {
        print("join join3");

        AwesomeNotifications().dismissAllNotifications();
      }
    });*/
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

  }
  getCurrentCall() async {
    //check current call from pushkit if possible
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        print('DATA: $calls');
        _currentUuid = calls[0]['id'];
        return calls[0];
      } else {

        return null;
      }
    }
  }

  checkAndNavigationCallingPage() async {
    var currentCall = await getCurrentCall();
    if (currentCall != null) {
 print(";;");
      NavigationService.instance
          .pushNamedIfNotCurrent(AppRoute.callingPage, args: currentCall);
    }else{
      print(";; fuck");
      NavigationService.instance
          .pushNamedIfNotCurrent(AppRoute.homePage, args: currentCall);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WebRTC"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20, right: 10),
                  hintText: "Enter your name to create profile"),
            ).visible(show),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: MaterialButton(
                color: Colors.blue,
                minWidth: 260,
                height: 50,
                onPressed: () {
                  FirebaseFirestore.instance.collection('data').add({
                    'name': textEditingController.text,
                    'token': deviceToken
                  });
                  setState(() {
                    show = false;
                  });
                },
                child: Text(
                  "submit",
                ),
              ),
            ).visible(show),
            Container(
              height: 250,
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('data').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((document) {
                      return Container(
                        child: Card(
                            child: InkWell(
                              onTap: () {
                                CallPage( document['name'],document['token']).launch(context,pageRouteAnimation: PageRouteAnimation.Slide);

                                log("show token"+document['token'].toString());
                              },
                              splashColor: Colors.grey,
                              child: Text(document['name']).paddingSymmetric(
                                  horizontal: 10, vertical: 20),
                            )),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> myBackgroundMessageHandler(RemoteMessage event) async {
  print("Background message/myBackgroundMessageHandler ${event.notification}");
  showCallkitIncoming(event);
  // Map message = event.data.toMap();
  // print('backgroundMessage: message => ${message.toString()}');
  // var payload = message['notification'];
/*  var item = jsonEncode(event.data);
  var userDetail = jsonDecode(item);

  print('abc:' + item);
  print('abc:' + userDetail['caller_name']);

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 0,
      channelKey: 'notification',
      title: userDetail['caller_name'] + 'is calling...',
      body: "",
    ),
    actionButtons: <NotificationActionButton>[
      NotificationActionButton(
        label: 'Decline',
        enabled: true,
        buttonType: ActionButtonType.DisabledAction,
        key: 'decline',
      ),
      NotificationActionButton(
        label: 'Accept',
        enabled: true,
        buttonType: ActionButtonType.Default,
        key: userDetail['room_id'],
        // key: 'accept-$roomId',
      )
    ],
  );*/
}
Future<void> showCallkitIncoming(RemoteMessage event) async {
  var item = jsonEncode(event.data);
  var userDetail = jsonDecode(item);

  print('abc:' + item);
  print('abc:' + userDetail['caller_name']);

  final params = CallKitParams(
    id:  userDetail['room_id'],
    nameCaller: userDetail['caller_name'],
    appName: 'Callkit',
    avatar: 'https://i.pravatar.cc/100',
    handle: '0123456789',
    type: 0,
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: const NotificationParams(
      showNotification: true,
      isShowCallback: true,
      subtitle: 'Missed call',

    ),
    // extra: <String, dynamic>{'userId': '1a2b3c4d'},
    // headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0955fa',
      backgroundUrl: 'assets/test.png',
      actionColor: '#4CAF50',
    ),
    ios: const IOSParams(
      iconName: 'CallKitLogo',
      handleType: '',
      supportsVideo: true,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default',
    ),
  );
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

