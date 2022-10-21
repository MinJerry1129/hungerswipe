// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hungerswipe/helpers/widgets/linearGradientLine.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'dart:io' show Platform;
// import 'package:phone_number/phone_number.dart';

class AccountLinks extends StatefulWidget {
  const AccountLinks({Key? key}) : super(key: key);
  _AccountLinksState createState() => _AccountLinksState();
}

class _AccountLinksState extends State<AccountLinks> {
  // double _currentMaxLocation = 1;
  // bool _loading = false;
  // bool _selected = false;
  // late FirebaseFirestore _firestore;
  // late FirebaseStorage _firebaseStorage;
  late FirebaseAuth _auth;
  late String number = "";
  bool google = false;
  bool twitter = false;
  bool apple = false;
  bool facebook = false;

  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    // _firestore = FirebaseFirestore.instance;
    // _firebaseStorage = FirebaseStorage.instance;

    _auth.currentUser!.providerData.asMap().forEach((key, value) {
      print(value);
      switch (value.providerId) {
        case "google.com":
          this.google = true;
          break;
        case "twitter.com":
          this.twitter = true;
          break;
        case "facebook.com":
          this.facebook = true;
          break;
        default:
      }
    });
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

    Future<UserCredential> _facebookLink() async {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      print("${loginResult.status} ${loginResult.accessToken!.token}");
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);
      setState(() {
        this.facebook = true;
      });
      return _auth.currentUser!.linkWithCredential(facebookAuthCredential);
    }

    Future<UserCredential> _googleLink() async {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      setState(() {
        this.google = true;
      });
      return await _auth.currentUser!.linkWithCredential(credential);
    }

    void _appleLink() {
      print('so does apple');
    }

    return MaterialApp(
        home: Scaffold(
            // main column
            body: SingleChildScrollView(
                child: Column(children: [
      Container(
          color: Color(0xFFFFFFFF),
          child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_ios,
                                  color: Color(0xFF7DCEFB)),
                              Text("Settings",
                                  style: TextStyle(
                                      color: Color(0xFF7DCEFB),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500))
                            ],
                          ),
                          onPressed: () => Navigator.of(context).pop()),
                      Text("Account Links",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Container(width: size.width * .2),
                    ],
                  )))),
      Column(children: [
        linearGradientLine(context, 3),
        Container(
            color: Color(0xFFF1F1F1),
            child: Row(
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 30, 0, 10),
                    child: Text("Account Links",
                        style: TextStyle(
                            color: Color(0xFF5A5A5A),
                            fontSize: 16,
                            fontWeight: FontWeight.w400))),
                Spacer()
              ],
            )),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Container(
                color: Colors.white,
                child: Column(children: [
                  // TextButton(
                  //     onPressed: () {},
                  //     child: Row(
                  //       children: [
                  //         Text("Sign in with Instagram",
                  //             style: TextStyle(
                  //                 color: Colors.black,
                  //                 fontWeight: FontWeight.w400,
                  //                 fontSize: 16)),
                  //       ],
                  //     )),
                  TextButton(
                      onPressed: _appleLink,
                      child: Row(
                        children: [
                          Text("Sign in with Apple",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16)),
                        ],
                      )),
                  Padding(
                      child: linearGradientLine(context, 1.5),
                      padding: EdgeInsets.only(left: 10)),
                  this.facebook
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: Row(
                            children: [
                              Text("Linked with Facebook",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16)),
                              Spacer(),
                              Icon(Icons.check,
                                  color: Color(0xFF7DCEFB), size: 14)
                            ],
                          ))
                      : TextButton(
                          onPressed: _facebookLink,
                          child: Row(
                            children: [
                              Text("Sign in with Facebook",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16)),
                            ],
                          )),
                  Padding(
                      child: linearGradientLine(context, 1.5),
                      padding: EdgeInsets.only(left: 10)),
                  this.google
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: Row(
                            children: [
                              Text("Linked with Google",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16)),
                              Spacer(),
                              Icon(Icons.check,
                                  color: Color(0xFF7DCEFB), size: 14)
                            ],
                          ))
                      : TextButton(
                          onPressed: _googleLink,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Sign in with Google",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16)),
                            ],
                          )),
                ])))
      ]),
      Container(
        color: Color(0xFFF1F1F1),
        height: MediaQuery.of(context).size.height,
        child: Text(
            "Linking your Google account will update your HungerSwipe account's email to match your Google email.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12)),
      ),
    ]))));
  }
}
