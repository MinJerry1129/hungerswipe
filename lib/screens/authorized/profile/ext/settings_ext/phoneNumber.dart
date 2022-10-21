import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/widgets/linearGradientLine.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:phone_number/phone_number.dart';

class SettingsPhoneNumber extends StatefulWidget {
  const SettingsPhoneNumber({Key? key}) : super(key: key);
  _SettingsPhoneNumberState createState() => _SettingsPhoneNumberState();
}

class _SettingsPhoneNumberState extends State<SettingsPhoneNumber> {
  double _currentMaxLocation = 1;
  bool _loading = false;
  bool _selected = false;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _firebaseStorage;
  late FirebaseAuth _auth;
  late String number = "";

  Future<String> parseNumber(String? number) async {
    RegionInfo region =
        RegionInfo(name: "United States", code: "US", prefix: 1);
    var parsed = await PhoneNumberUtil().format(number ?? "", region.code);
    return parsed;
  }

  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _firebaseStorage = FirebaseStorage.instance;

    parseNumber(_auth.currentUser!.phoneNumber).then((val) {
      setState(() {
        number = val;
      });
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
                      Text("Phone Number",
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
                    child: Text("Phone Number",
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
                  TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Text("$number",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16)),
                          Spacer(),
                          Icon(Icons.check, color: Color(0xFF7DCEFB), size: 24)
                        ],
                      )),
                ])))
      ]),
      Container(
        color: Color(0xFFF1F1F1),
        height: MediaQuery.of(context).size.height,
      ),
    ]))));
  }
}
