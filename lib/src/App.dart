import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:anytelnet/src/Controller.dart';
import 'package:anytelnet/src/routes.dart';
import 'package:anytelnet/src/screens/home_screen.dart';
import 'package:anytelnet/src/screens/telnet_screen.dart';
class MVC_telnet_APP extends AppMVC {
  MVC_telnet_APP({Key key}) : super(con: _controller, key: key);

  static final Con _controller = Con();
  static MaterialApp _app;
  static String get title => _app.title.toString();
  Widget build(BuildContext context) {
    _app = MaterialApp(
      title: 'mvc telnet example',
      routes: {
        ArchSampleRoutes.home: (context) => HomeScreen(),
        ArchSampleRoutes.goTelnet: (context) => TelnetScreen(),
      },
    );
    return _app;
  }
}

