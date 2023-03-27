import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webrtc/receiveCall.dart';
import 'Signaling.dart';
import 'api.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'callPage.dart';

User user = User(
    name: "Yash Makan",
    email: "yashmakan.fake.email@gmail.com",
    gender: "Male",
    phoneNumber: "9999999999",
    birthDate: 498456350,
    username: "yashmakan",
    password: "79aa7b81bcdd14fd98282b810b61312b",
    firstName: "Yash",
    lastName: "Makan",
    title: "Full Stack Developer",
    firebaseToken:
        "d600MGj1Q429tQktEUpx49:APA91bFCkY3bGX1IuNU5z6lkJ73Tih0Mgxssh39ggdV8PB3XXBcDNSTmpMNPbpd3bNQwcm5k5hbdaoDf1-ALKWZYm5uJkXiWiq_TWqnAbw8V-vPGYafo-aLi7vLBUlxCbolRuFrk2U7y",
    uuid: "",
    picture:
        "https://images.unsplash.com/photo-1453396450673-3fe83d2db2c4?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80");

User rick = User(
    name: "Rick Rolland",
    email: "rick.fake.email@gmail.com",
    gender: "Male",
    phoneNumber: "8888888888",
    birthDate: 498456351,
    username: "rickkk",
    password: "79aa7b81bcdd14fd98282b810b61312a",
    firstName: "Rick",
    lastName: "Rolland",
    title: "Web Developer",
    firebaseToken:
        "d600MGj1Q429tQktEUpx49:APA91bFCkY3bGX1IuNU5z6lkJ73Tih0Mgxssh39ggdV8PB3XXBcDNSTmpMNPbpd3bNQwcm5k5hbdaoDf1-ALKWZYm5uJkXiWiq_TWqnAbw8V-vPGYafo-aLi7vLBUlxCbolRuFrk2U7y",
    uuid: "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    picture:
        "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2");
late PackageInfoData packageInfo;

late String initialRoute = "/";
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
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) =>   Receive(),
      },

    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
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

    super.initState();
    FirebaseMessaging.onMessage.listen((event) {
      myBackgroundMessageHandler(event);
    });
    AwesomeNotifications().actionStream.listen((event) {
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
    });
  }

  @override
  void dispose() {
    super.dispose();
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
  // Map message = event.data.toMap();
  // print('backgroundMessage: message => ${message.toString()}');
  // var payload = message['notification'];
  var item = jsonEncode(event.data);
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
  );
}

/*Future _showNotificationWithDefaultSound(flip) async {
    print("show notification");
  // Show a notification after every 15 minute with the first
  // appearance happening a minute after invoking the method
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'pushnotification',
      'pushnotification',
       importance: Importance.max,
      priority: Priority.high
  );
  var iOSPlatformChannelSpecifics = new DarwinNotificationDetails();

  // initialise channel platform for both Android and iOS device.
  var platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics
  );
  await flip.show(0,  "is Calling",
      'Your are one step away to connect with GeeksforGeeks',
      platformChannelSpecifics, payload: 'Default_Sound'
  );
}
*/
