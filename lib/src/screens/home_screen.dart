// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:anytelnet/src/routes.dart';
import 'package:anytelnet/src/Controller.dart';

class HomeScreen extends StatefulWidget {
  @protected
  @override
  createState() => HomeView();
}

class HomeView extends State<HomeScreen> {

  final Con _con = Con.con;
  TextEditingController _deviceController = new TextEditingController();
  TextEditingController _portController = new TextEditingController();
  /*
  TextEditingController _unameController = new TextEditingController();
  TextEditingController _pwdController = new TextEditingController();
  */
  @protected
  @override
  void initState() {
    super.initState();

    /// Calls the Controller when this one-time 'init' event occurs.
    /// Not revealing the 'business logic' that then fires inside.
    print("super init");
    _con.init();
  }
  bool _select_without_username_password = false;

  @protected
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /// The View need not know nor care what the title is. The Controller does.
        title: Text(_con.title),
      ),
      body:
      Container(
       //margin: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _deviceController,
              autofocus: true,
              decoration: InputDecoration(labelText: "IP-address",
                hintText: "Input your device's IP-address",
                prefixIcon: Icon(Icons.device_hub),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _portController,
              autofocus: true,
                decoration: InputDecoration(labelText: "Port",
                hintText: "Input Port",
                prefixIcon: Icon(Icons.extension)
              ),
              keyboardType: TextInputType.number,
            ),
            /*
            TextField(
              controller: _unameController,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: "username",
                  hintText: "Input your device's username",
                  prefixIcon: Icon(Icons.person)
              ),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: _pwdController,
              decoration: InputDecoration(
                  labelText: "password",
                  hintText: "Input your password",
                  prefixIcon: Icon(Icons.lock)
              ),
              obscureText: true,
              keyboardType: TextInputType.text,
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Switch(
                    value: _select_without_username_password,
                    onChanged: (value) {
                      setState(() {
                        _select_without_username_password = value;
                      });
                    },
                  ),
                  Text("without username and password"),
                ],
              ),
            ),*/
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      //padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0, bottom: 5.0),
                      child: Text("Login"),
                      color: Theme
                          .of(context)
                          .primaryColor,
                      textColor: Colors.white,
                      onPressed: () {
                        _con.login(_deviceController.text, int.parse(_portController.text));
                        Navigator.pushNamed(context, ArchSampleRoutes.goTelnet);
                      },
                    ),
                  )
                ],
              ),
            )
            /*
          Switch(
            value: _select_without_username_password,
            onChanged: (value) {
              setState(() {
                _select_without_username_password = value;
              });
            },
          ),
          Text("without username and password"
          ),*/
            /*
            RaisedButton(

              //padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0, bottom: 5.0),
              child: Text("Login"),
              color: Theme
                  .of(context)
                  .primaryColor,
              textColor: Colors.white,
              onPressed: () {
                _con.login(_deviceController.text, _unameController.text, _pwdController.text);
                Navigator.pushNamed(context, ArchSampleRoutes.goTelnet);
              },
            ),*/
            /*
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: Row(
              children: <Widget>[
                Switch(
                  value: _select_without_username_password,
                  onChanged: (value) {
                    setState(() {
                      _select_without_username_password = value;
                    });
                  },
                ),
                Text("without username and password"
                ),
              ],
            )
            ,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.all(15.0),
                    child: Text("Login"),
                    color: Theme
                        .of(context)
                        .primaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      _con.login(_deviceController.text, _unameController.text, _pwdController.text);
                      Navigator.pushNamed(context, ArchSampleRoutes.goTelnet);
                    },
                  ),
                ),
              ],
            ),
          )*/
          ],
        ),
      ),

    );
  }

}
