
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:nb_utils/nb_utils.dart';

import 'Signaling.dart';
import 'api.dart';
class Receive extends StatefulWidget {



  @override
  State<Receive> createState() => _ReceiveState();

 }

class _ReceiveState extends State<Receive> {
  late CallKitParams? calling;

  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  @override
  void initState() {
     super.initState();
     _localRenderer.initialize();
     _remoteRenderer.initialize();

     signaling.onAddRemoteStream = ((stream) {
       _remoteRenderer.srcObject = stream;
       setState(() {});
     });
  }
  @override
  void dispose() {
    // _localRenderer.dispose();
    // _remoteRenderer.dispose();
    // signaling.hangUp(_localRenderer);
    end();
    super.dispose();
    remove();
  }
  remove() async {
    await removeKey(TOKEN);
  }
  end() async{
    if (calling != null) {
      await makeEndCall(calling!.id!);
      calling = null;
    }
  }
  @override
  Widget build(BuildContext context) {
    final params = jsonDecode(jsonEncode(
        ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>));
    print(ModalRoute.of(context)!.settings.arguments);
    calling = CallKitParams.fromJson(params);
    return   Scaffold(
      appBar: AppBar(title: Text(getStringAsync(USER_NAME)),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          30.height,
          MaterialButton(
            color: Colors.lightGreen,
              onPressed:() {
                signaling.openUserMedia(_localRenderer, _remoteRenderer);
                signaling.joinRoom(
                getStringAsync(TOKEN),
                  _remoteRenderer,
                );
              },
          child: Text(getStringAsync(USER_NAME)).paddingAll(12),),
          10.height,
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
        ],
      ),
    );
  }
  Future<void> makeEndCall(id) async {
    await FlutterCallkitIncoming.endCall(id);
  }
}
