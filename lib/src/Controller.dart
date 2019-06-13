import 'dart:async' show Future;
import 'package:mvc_pattern/mvc_pattern.dart' show ControllerMVC;
import 'package:anytelnet/src/App.dart';
import 'package:anytelnet/src/Model.dart';
import 'dart:convert';
import 'dart:io';

class Con extends ControllerMVC {
  factory Con() {
    if (_this == null) {
      _this = Con._();
    }
    return _this;
  }
  static Con _this;
  Con._();
  static Con get con => _this;
  String get title => MVC_telnet_APP.title;

  void init() => loadData();
  static final model = Model();
  Future<List<int>> loadData() async {
    var load = await model.loadList();

    return load;
  }
  void close()
  {
    print("close socket");
    model.close();
  }
  send(String cmd, EventCallback func) async
  {
    await model.send(cmd, func);
  }
  /* here should have an login method */
  void login(String device_ip, int port)
  {
    print("login...");
    model.connect(device_ip, port);
    refresh();
  }
  static List<int> get con_reply => model.reply;

  get_reply() async
  {
    if (model.reply.isEmpty == true) {
      print("empty");
      return await "no response";
    } else {
      return await utf8.decode(model.reply);
    }
  }

  /* here should have send and get reply method */
}