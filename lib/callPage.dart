import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:nb_utils/nb_utils.dart';

import 'Signaling.dart';
import 'api.dart';

class CallPage extends StatefulWidget {
  String name;
  String token;

  @override
  State<CallPage> createState() => _CallPageState();

  CallPage(this.name, this.token);
}

class _CallPageState extends State<CallPage> {

  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
     super.initState();
  }
  @override
  void dispose() {
    signaling.hangUp(_localRenderer);
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();

  }

  @override

  Widget build(BuildContext context) {

    return  Scaffold(
      appBar: AppBar(title:Text(widget.name!) ),
        body: Stack(
      children: [
        Center(
          child: Container(

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                50.height,
                 MaterialButton(
                  elevation: 4,
                  minWidth: 120,
                  height: 50,
                  color: Colors.lightGreen,
                  onPressed:() async {
                    signaling.openUserMedia(_localRenderer, _remoteRenderer);
                    roomId = await signaling.createRoom(_remoteRenderer);
                  Api.sendNotificationRequestToFriendToAcceptCall(roomId!,widget.name,widget.token);
                    setState(() {});
                },
                child: Text('Create ').paddingAll(10),),
                20.height,
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
          ),
        )
      ],
    ));
  }



}
