import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/customIndicator.dart';
import 'package:hungerswipe/helpers/widgets/gradientButton.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:hungerswipe/screens/authorized/tab_controller/tab_controller.dart';
import 'package:http/http.dart' show Client;

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  var endpoint = 'https://us-central1-hungerswipe.cloudfunctions.net';
  bool isActive = false;
  bool loading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map _userData = AppStateScope.of(context).userData;
    Client client = Client();
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    FirebaseMessaging _messaging = FirebaseMessaging.instance;
    // final Map _userData = AppStateScope.of(context).userData;

    var statusBarHeight = MediaQuery.of(context).padding.top;
    var width = MediaQuery.of(context).size.width;

    void _handleUpdate() async {
      if (Platform.isIOS) {
        await _messaging.requestPermission(
            alert: true,
            announcement: true,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true);
      }

      await _firestore
          .collection('users')
          .doc(_userData['phoneNumber'])
          .update({"notificationAccess": true});
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => Tabs()),
          (route) => false);
    }

    void _handleNotAllowed() async {
      await _firestore
          .collection('users')
          .doc(_userData['phoneNumber'])
          .update({"notificationAccess": false});
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
            padding: EdgeInsets.only(top: statusBarHeight + 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back_ios_new,
                              color: LightModeColors["primary"], size: 24.0)),
                      customIndicator(context, 50),
                      Container(width: 24),
                    ]),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text('Notifications',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold))),
                Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Container(
                      width: width / 1.5,
                      height: 300,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              begin: Alignment(0.1, -1),
                              colors: [
                                Color(0x40E54AAF),
                                Color(0x40F3B3D6),
                                Color(0x407DCEFB),
                              ])),
                      child: Icon(Icons.message, size: 64, color: Colors.white),
                    )),
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Container(
                        width: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "Allowing notifications will provide you with updates like new messages, or matches.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: LightModeColors["helperText"],
                                    fontSize: 16)),
                          ],
                        ))),
                Spacer(),
                gradientButton(context, _handleUpdate, "Allow"),
                Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: TextButton(
                        onPressed: _handleNotAllowed,
                        child: Text("Not Now",
                            style: TextStyle(color: Colors.grey))))
              ],
            )));
  }
}
