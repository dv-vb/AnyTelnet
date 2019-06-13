
import 'package:flutter/material.dart';
import 'package:anytelnet/src/Controller.dart';
import 'dart:convert';
import 'package:anytelnet/src/Model.dart';

class TelnetScreen extends StatefulWidget {

  @override
  _telnet_screen createState() => _telnet_screen();
}

class _telnet_screen extends State<TelnetScreen> {
  final Con _con = Con.con;
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController _cmdController = new TextEditingController();
  static String data = "empty";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("telneting..."),
      ),

      body: Padding(
        padding: EdgeInsets.all(5.0),
        child: Form(
          key: formKey,
          autovalidate: false,
          onWillPop: () {
            _con.close();
            return Future(() => true);
          },
          child:Column(
            children: <Widget>[
              Container(
                child:
                TextField(
                  controller: _cmdController,
                  autofocus: true,
                  decoration: InputDecoration(labelText: "Cmd",
                    hintText: "Input your cli command",
                    prefixIcon: Icon(Icons.comment),
                  ),
                  onSubmitted: input_cmd_submit,
                  keyboardType: TextInputType.text,
                ),
              ),
              Expanded(
                child: Container(
                  child: ListView(
                    padding: EdgeInsets.all(3.0),
                    children: <Widget> [
                      Text(data, textAlign: TextAlign.left, style: TextStyle(fontSize: 12.00, fontFamily: "Courier", color: Colors.black),),
                    ],
                  ),
                ),
              ),

            ],
          ),


          /*Column(
            children: <Widget>[
              TextField(
                controller: _cmdController,
                autofocus: true,
                decoration: InputDecoration(labelText: "Cmd",
                  hintText: "Input your cli command",
                  prefixIcon: Icon(Icons.comment),
                ),
                onSubmitted: input_cmd_submit,
                keyboardType: TextInputType.text,
              ),
              ListView(
                padding: EdgeInsets.all(16.0),
                children: <Widget> [
                  Text(data),
                ],
              ),
            ],
          )*/

          /*
          FutureBuilder(
                future: _con.loadData(),
                builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot){
                  if (snapshot.hasData) {
                    List<int> reply = snapshot.data;
                    return ListView(
                      padding: EdgeInsets.all(16.0),
                      children: <Widget> [
                        Text("${utf8.decode(reply)}")
                      ],
                    );
                  } else {
                    return Text("loading...");
                  }
                },
              )
            FutureBuilder(
                future: _con.loadData(),
                builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot){
                  if (snapshot.hasData) {
                    List<int> reply = snapshot.data;
                    return ListView(
                      padding: EdgeInsets.all(16.0),
                      children: <Widget> [
                        Text("${utf8.decode(reply)}")
                      ],
                    );
                  }
                },
              )
          */
        ),
      )
    );
  }
  void get_cmd_reply(String str)
  {
    data = str;
    _con.refresh();
  }

  void input_cmd_submit(String str) async
  {
    print("input cmd ${str}");
    await _con.send(_cmdController.text, get_cmd_reply);
    _cmdController.clear();
    _con.refresh();
  }
}
