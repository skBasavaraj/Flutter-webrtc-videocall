import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:nb_utils/nb_utils.dart';

import 'Signaling.dart';
import 'api.dart';
class Receive extends StatefulWidget {



  @override
  State<Receive> createState() => _ReceiveState();

 }

class _ReceiveState extends State<Receive> {
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
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    signaling.hangUp(_localRenderer);
    super.dispose();
    remove();

  }
  remove() async {
    await removeKey(TOKEN);
  }
  @override
  Widget build(BuildContext context) {
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
}
