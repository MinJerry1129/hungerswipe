// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hungerswipe/helpers/widgets/gradientText.dart';
import 'package:hungerswipe/helpers/widgets/linearGradientLine.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'dart:io' show Platform;

import 'package:intl/intl.dart';
// import 'package:phone_number/phone_number.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Map<String, dynamic>? data;
  // double _currentMaxLocation = 1;
  // bool _loading = false;
  // bool _selected = false;
  late FirebaseFirestore _firestore;
  bool hasNotifications = false;
  // late FirebaseStorage _firebaseStorage;
  late FirebaseAuth _auth;
  late String number = "";
  List friendsList = [];

  Future<void> getFriends() async {
    var _friends = _firestore.collection("friends");
    await _friends
        .doc(_auth.currentUser!.phoneNumber)
        .collection("active")
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        setState(() {
          friendsList.add(doc.id);
        });
      });
    });
  }

  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    // _firebaseStorage = FirebaseStorage.instance;
    getFriends();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext build) {
    var statusBarHeight = MediaQuery.of(context).padding.top;
    var size = MediaQuery.of(context).size;
    var _userData = AppStateScope.of(context).userData;

    Future<void> _acceptFriendRequest(senderId) async {
      var _notifications = _firestore.collection("notifications");
      var _friends = _firestore.collection("friends");
      var user = await _firestore.collection("users").doc(senderId).get();
      await _notifications.add({
        "type": "friend-request-accepted",
        "sender": '${_userData["firstName"]} ${_userData["lastName"]}',
        "tokens": user['tokens'],
        "message": "",
        "recipient": user['username'],
        "timestamp": DateTime.now(),
        "senderPhoto": _userData['profilePhoto'].isNotEmpty
            ? _userData['profilePhoto']
            : ""
      });

      await _friends
          .doc(_userData['phoneNumber'])
          .collection("requests")
          .doc(user['phoneNumber'])
          .delete();

      await _friends
          .doc(user['phoneNumber'])
          .collection("outgoing")
          .doc(_userData['phoneNumber'])
          .delete();

      await _friends
          .doc(_userData['phoneNumber'])
          .collection("active")
          .doc(user['phoneNumber'])
          .set({"friends": true});

      await _friends
          .doc(user['phoneNumber'])
          .collection("active")
          .doc(_userData['phoneNumber'])
          .set({"friends": true});

      setState(() {
        friendsList.add(senderId);
      });
    }

    return MaterialApp(
        home: Scaffold(
            // main column
            body: Column(children: [
      Container(
          color: Color(0xFFFFFFFF),
          child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      Text("Notifications",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Container(width: size.width * .2),
                      TextButton(
                          child: Text("Done",
                              style: TextStyle(
                                  color: Color(0xFF7DCEFB),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500)),
                          onPressed: () => Navigator.of(context).pop()),
                    ],
                  )))),
      linearGradientLine(context, 2),
      StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection("notifications")
              .orderBy("timestamp")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState == ConnectionState.waiting)
              return Text("loading");
            if (snapshot.data!.docs.length == 0) return Container();

            return Flexible(
              child: ListView(
                padding: EdgeInsets.all(10),
                scrollDirection: Axis.vertical,
                physics: AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      data = document.data() as Map<String, dynamic>;
                      Map notification = data!;
                      bool hasPhoto = data?['senderPhoto'] != null;
                      var notificationType = data?['type'];
                      bool isAdded = friendsList.contains(data!['senderId']);
                      bool needsResponse =
                          notificationType == "friend-request" ||
                              notificationType == "message";
                      String message =
                          " ${notificationType == 'friend-request' ? 'wants to be your friend' : notificationType == 'message' ? 'sent you a message' : notificationType == 'friend-request-accepted' ? 'accepted your friend request' : ''}";
                      if (notification['recipient'] == _userData['username']) {
                        return !hasNotifications
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: 12, left: 15),
                                        child: Container(
                                          height: 46,
                                          width: 46,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(36),
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            backgroundImage: hasPhoto
                                                ? NetworkImage(
                                                    notification['senderPhoto'])
                                                : AssetImage(
                                                        'images/Icons/no-user.jpg')
                                                    as ImageProvider,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Container(
                                              width: size.width * .5,
                                              child: AutoSizeText.rich(
                                                  TextSpan(children: [
                                                TextSpan(
                                                    text:
                                                        notification['sender'],
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16)),
                                                TextSpan(
                                                    text: message,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF999999),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500))
                                              ])))),
                                      needsResponse
                                          ? LayoutBuilder(
                                              builder: (BuildContext context,
                                                  BoxConstraints constraints) {
                                                return Container(
                                                    height: constraints
                                                        .constrainHeight(35),
                                                    width: constraints.constrainWidth(
                                                        size.width * .2),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color: Color(
                                                                0xFFC4C4C4),
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.25),
                                                            spreadRadius: -5,
                                                            blurRadius: 10,
                                                            offset:
                                                                Offset(2, 1),
                                                          )
                                                        ]),
                                                    child: Padding(
                                                        child: !isAdded
                                                            ? TextButton(
                                                                onPressed: () => _acceptFriendRequest(data![
                                                                    'senderId']),
                                                                child: AutoSizeText(
                                                                    "Confirm",
                                                                    style: TextStyle(color: Colors.black, fontSize: 16)))
                                                            : Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            5),
                                                                child: GradientText(
                                                                    "Friends",
                                                                    centerText:
                                                                        true,
                                                                    gradient:
                                                                        LinearGradient(
                                                                            colors: [
                                                                          Color(
                                                                              0x96F169B6),
                                                                          Color(
                                                                              0x96F3B3D6),
                                                                          Color(
                                                                              0x967DCFFB),
                                                                        ]),
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                        padding: EdgeInsets.symmetric(horizontal: 5)));
                                              },
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                ],
                              )
                            : Column();
                      } else {
                        return SizedBox.shrink();
                      }
                    })
                    .toList()
                    .reversed
                    .toList(),
              ),
            );
          })
    ])));
  }
}
