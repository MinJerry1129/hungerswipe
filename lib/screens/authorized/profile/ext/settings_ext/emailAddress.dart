import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/widgets/linearGradientLine.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/settings_ext/widgets/emailInput.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:phone_number/phone_number.dart';

class EmailAddress extends StatefulWidget {
  const EmailAddress({Key? key}) : super(key: key);
  _EmailAddressState createState() => _EmailAddressState();
}

class _EmailAddressState extends State<EmailAddress> {
  double _currentMaxLocation = 1;
  bool _loading = false;
  bool _selected = false;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _firebaseStorage;
  late FirebaseAuth _auth;
  late String number = "";
  String verificationMessage = "";
  bool verified = false;
  bool emailAdded = false;

  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _firebaseStorage = FirebaseStorage.instance;
    _auth.currentUser!.reload();
    this.verified = _auth.currentUser!.emailVerified;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleVerification() async {
    String? _email = _auth.currentUser!.email;
    await _auth.currentUser!.sendEmailVerification();
    setState(() {
      this.verificationMessage = "Verification sent.";
    });
  }

  @override
  Widget build(BuildContext build) {
    var statusBarHeight = MediaQuery.of(context).padding.top;
    var size = MediaQuery.of(context).size;
    var _userData = AppStateScope.of(context).userData;

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
                      Text("Email Address",
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
                    child: Text("Email Address",
                        style: TextStyle(
                            color: Color(0xFF5A5A5A),
                            fontSize: 16,
                            fontWeight: FontWeight.w400))),
                Spacer()
              ],
            )),
        Container(
            color: Colors.white,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (BuildContext context) => EmailInput())),
                      child: Row(
                        children: [
                          Text(
                              "${_auth.currentUser!.email != null ? _auth.currentUser!.email : "Add Email"}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16)),
                          Spacer(),
                          Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(
                                  !verified
                                      ? Icons.arrow_forward_ios
                                      : Icons.check,
                                  color: !verified
                                      ? Color(0xFF999999)
                                      : Color(0xFF7DCEFB),
                                  size: 14))
                        ],
                      )),
                ]))),
        Container(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Text(
                    verified ? "Your email is verified." : verificationMessage,
                    style: TextStyle(color: Color(0xFF7DCEFB)))),
            color: Color(0xFFF1F1F1),
            width: size.width,
            height: 50),
        Container(
          color: !verified ? Color(0xFF7DCEFB) : Colors.white,
          width: MediaQuery.of(context).size.width,
          child: TextButton(
            onPressed: _handleVerification,
            child: Text("Send Email Verification",
                style: TextStyle(
                    color: Color(!verified && _auth.currentUser!.email != null
                        ? 0xFFFFFFFF
                        : 0xFF999999),
                    fontWeight: FontWeight.w400,
                    fontSize: 16)),
          ),
        )
      ]),
      Container(
        color: Color(0xFFF1F1F1),
        height: MediaQuery.of(context).size.height,
      ),
    ]))));
  }
}
