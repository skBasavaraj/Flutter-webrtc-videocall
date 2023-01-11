import 'dart:convert';

 import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
  import 'Signaling.dart';
import 'api.dart';
import 'package:awesome_notifications/awesome_notifications.dart';



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
    firebaseToken: "d600MGj1Q429tQktEUpx49:APA91bFCkY3bGX1IuNU5z6lkJ73Tih0Mgxssh39ggdV8PB3XXBcDNSTmpMNPbpd3bNQwcm5k5hbdaoDf1-ALKWZYm5uJkXiWiq_TWqnAbw8V-vPGYafo-aLi7vLBUlxCbolRuFrk2U7y",  uuid:"",
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
    firebaseToken: "d600MGj1Q429tQktEUpx49:APA91bFCkY3bGX1IuNU5z6lkJ73Tih0Mgxssh39ggdV8PB3XXBcDNSTmpMNPbpd3bNQwcm5k5hbdaoDf1-ALKWZYm5uJkXiWiq_TWqnAbw8V-vPGYafo-aLi7vLBUlxCbolRuFrk2U7y",
    uuid: "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",

    picture:
    "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2");
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AwesomeNotifications().initialize( null, [NotificationChannel(channelKey:'notification', channelName: 'notification', channelDescription:  "hello world",
  defaultColor: Colors.red,playSound: true,enableVibration: true)] );
 FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');



  @override
  void initState() {
    FirebaseMessaging? _firebaseMessaging =FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((token){
      print("token is $token");
    });
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
    FirebaseMessaging.onMessage.listen((event)   {
       myBackgroundMessageHandler(event);
    });
    AwesomeNotifications().actionStream.listen((event) {
      if(event.buttonKeyPressed.isNotEmpty){
        print("join join1${event.buttonKeyPressed}");
        signaling.openUserMedia(_localRenderer, _remoteRenderer);
        signaling.joinRoom(
          event.buttonKeyPressed,
          _remoteRenderer,
        );
        print("join join2");

      }else if(event.buttonKeyPressed=="decline"){
        print("join join3");

        AwesomeNotifications().dismissAllNotifications();
      }
    });


  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Flutter Explained - WebRTC"),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                },
                child: Text("Open camera & microphone"),
                
              ),
              ElevatedButton(onPressed:   () {
             //   Api.sendNotificationRequestToFriendToAcceptCall( "", user);

              }, child: Text("")),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () async {
                  signaling.openUserMedia(_localRenderer, _remoteRenderer);
                  print("Open camera & microphone");
                  roomId = await signaling.createRoom(_remoteRenderer);
                  print("room  created");
                  textEditingController.text = roomId!;
                  Api.sendNotificationRequestToFriendToAcceptCall( roomId!, user);

                  setState(() {});
                },
                child: Text("Create room"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  // Add roomId
                  signaling.joinRoom(
                    textEditingController.text,
                    _remoteRenderer,
                  );
                },
                child: Text("Join room"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  signaling.hangUp(_localRenderer);
                },
                child: Text("End call"),
              )
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
 }

Future<void> myBackgroundMessageHandler(RemoteMessage event) async {
  print("Background message/myBackgroundMessageHandler ${event.notification}");
  // Map message = event.data.toMap();
  // print('backgroundMessage: message => ${message.toString()}');
  // var payload = message['notification'];
   var item =   jsonEncode(event.data);
     var userDetail = jsonDecode(item);

   print('abc:'+  item);
  print('abc:'+ userDetail['caller_name']);


  AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,

        channelKey: 'notification',

        title:userDetail['caller_name']+ 'is calling...',
        body: "",
       ),
      actionButtons:<NotificationActionButton> [
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
           key:userDetail['room_id'],
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