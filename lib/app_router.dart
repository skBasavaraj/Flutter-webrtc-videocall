import 'package:flutter/material.dart';

import 'package:webrtc/receiveCall.dart';

import 'main.dart';

class AppRoute {
  static const homePage = '/main';

  static const callingPage = '/receiveCall';

  static Route<Object>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(
            builder: (_) => MyHomePage( title: '',), settings: settings);
      case callingPage:
        return MaterialPageRoute(
            builder: (_) => Receive(), settings: settings);
      default:
        return null;
    }
  }
}