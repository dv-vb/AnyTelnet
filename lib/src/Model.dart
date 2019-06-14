import 'dart:io';
import 'dart:async';
import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gbk2utf8/gbk2utf8.dart';

typedef void EventCallback(String str);

class Model {
  /* maintenance the url */
  static var socket;
  List<int> get reply => respone;
  List<int> respone;
  EventCallback get_send_reply;
  Future<List<int>> loadList() async {
    if (respone == null) {
      respone = new List();
    }
    return await respone;
  }

  void close()
  {
    print("close socket and destroy.");
    socket.close();
    socket.destroy();
  }
  send(String cmd, EventCallback func) async
  {
    respone.clear();
    get_send_reply = func;
    socket.writeln(cmd);
    //socket.join();
    await socket.flush();
    //return await socket.transform(utf8.decoder).join();
  }

  void connect(String device_ip, int port) async
  {
    print(device_ip);
    print(port);
    socket = await Socket.connect(device_ip, port);
    print(socket.runtimeType);
    print(socket.toString());
    //socket.listen(sock_recieve);
    socket.listen(sock_recieve);
    respone.clear();
    //socket.writeln("?");
    //
    //await socket.flush();
    //var reply = await socket.transform(utf8.decoder).join();
    //print(reply);
  }
  void telnet_win_size()
  {
    //var win_size_reply = const [255, 251, 31];
    //ff fd 01
    //255, 250, 31, 0, 120, 0, 30, 255, 240
    var cur_win_size = const [255, 253, 1, 0xff, 0xfa, 0x1f, 0x00, 0xf0, 0x00, 0xf0,  0xff, 0xf0];
    print("send windows size");
    print(cur_win_size.toString());
    socket.add(cur_win_size);
  }

  void sock_negotiate(List<int> value)
  {
    print(value.length);
    double times = value.length / 3;
    print(times.toInt());
    int i = 0;
    for (i = 0; i < times.toInt(); i++) {
      List<int> tmp = value.sublist(i*3, i*3 + 3);
      print(tmp);
      if (tmp[0] == 255 && tmp[1] == 253 && tmp[2] == 31) {
        telnet_win_size();
      }
    }
  }
  void add_to_repsone(int f)
  {
    respone.add(f);
  }

  void sock_recieve (List<int> value)
  {
    print("recieving...");
    if (value[0] == 0xff) {
      print("get negotiate.");
      print(value);
      sock_negotiate(value);
    } else {
      value.forEach(add_to_repsone);
      /* TODO: Don't Support GBK */
      var reply_string;
      try {
        reply_string = utf8.decode(value);
        print(reply_string);
        if (get_send_reply != null) {
          get_send_reply(utf8.decode(respone));
        }
      } catch (e) {
        print("no utf8");
        try {
          reply_string = ascii.decode(value);
          print(reply_string);
          if (get_send_reply != null) {
            get_send_reply(ascii.decode(respone));
          }
        } catch (e) {
          print("no ascii");
          try {
            reply_string = gbk.decode(value);
            print(reply_string);
            if (get_send_reply != null) {
              get_send_reply(gbk.decode(respone));
            }
          } catch (e) {
            print("no gbk");
            try {
              reply_string = latin1.decode(value);
              print(reply_string);
              if (get_send_reply != null) {
                get_send_reply(latin1.decode(respone));
              }
            } catch (e) {
              print("no latin1");
            }
          }
        }
      }
      //print(utf8.decode(value));
      /* add to table view
      * try {
            reply_string = latin1.decode(value);
            print(reply_string);
            if (get_send_reply != null) {
              get_send_reply(latin1.decode(respone));
            }
          } catch (e) {
            print("no latin1");
          }
      * */

    }
    print("end");
  }

}