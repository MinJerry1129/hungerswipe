import 'dart:convert';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http/http.dart' as Http;
// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hungerswipe/helpers/widgets/linearGradientLine.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/settings_ext/accountLinks.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/settings_ext/allergies.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/settings_ext/emailAddress.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/settings_ext/emailnotifs.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/settings_ext/phoneNumber.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/settings_ext/pushnotifs.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/settings_ext/readreceipts.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/settings_ext/settingsLocation.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:phone_number/phone_number.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  double _currentMaxLocation = 1;
  bool _loading = false;
  bool _selected = false;
  bool modeChange = false;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _firebaseStorage;
  late FirebaseAuth _auth;
  late FirebaseFunctions _functions;
  String number = "";

  Future<String> parseNumber(String? number) async {
    RegionInfo region =
        RegionInfo(name: "United States", code: "US", prefix: 1);
    var parsed = await PhoneNumberUtil().format(number ?? "", region.code);
    return parsed;
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;

    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      var endpoint =
          "https://maps.googleapis.com/maps/api/geocode/json?sensor=true&key=AIzaSyB1J6ulWGC7DhDJtlNu22c9UhZjW-W1_H4&latlng=";
      var position = await Geolocator.getCurrentPosition();
      Http.Response response = await Http.get(
          Uri.parse('$endpoint${position.latitude},${position.longitude}'));
      print('hapapa ${response.body}');
    }
  }

  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _firebaseStorage = FirebaseStorage.instance;
    _functions = FirebaseFunctions.instance;
    // returns city, state. will need eventually
    // _determinePosition();
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
    bool darkMode = _userData['modePreference'] == 'light-mode' ? false : true;
    void _handleSaveSettings() {
      if (modeChange)
        Phoenix.rebirth(context);
      else
        Navigator.of(context).pop();
    }

    void _handleChangePhoneNumber() async {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => SettingsPhoneNumber()));
    }

    void _handleSocialMedia() {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => AccountLinks()));
    }

    void _handleChangeEmail() {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => EmailAddress()));
    }

    void _handleLocation() {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => SettingsLocation()));
    }

    void _handleChangeMaxLocation(double val) {
      _firestore
          .collection("users")
          .doc(_userData['phoneNumber'])
          .update({"location.radius": val.toInt()});
    }

    void _handleFoodAllergies() {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => SettingsAllergies()));
    }

    void _handleReadReceipts() {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => SettingsReadReceipts()));
    }

    void _handleEmailNotifications() {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => SettingsEmailNotifs()));
    }

    void _handlePushNotifications() {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => SettingsPushNotifs()));
    }

    void _handleDarkMode(preference) async {
      SharedPreferences _prefs = await SharedPreferences.getInstance();

      var modePreference = preference ? 'dark-mode' : 'light-mode';
      _firestore
          .collection("users")
          .doc(_userData['phoneNumber'])
          .update({"modePreference": modePreference});
      AppStateWidget.of(context)
          .updateUserData("modePreference", modePreference);
      setState(() {
        darkMode = preference;
      });
      await _prefs.setBool("darkMode", preference);

      setState(() {
        modeChange = !modeChange;
      });
    }

    void _handleHelpSupport() {}
    void _handleLogout() {}
    void _handleDeleteAccount() {}

    return MaterialApp(
        home: Scaffold(
            // main column
            body: SingleChildScrollView(
                child: Column(
      children: [
        Container(
            color: Color(0xFFFFFFFF),
            child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: size.width * .2),
                        Text("Settings",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        TextButton(
                            child: Text("Done",
                                style: TextStyle(
                                    color: Color(0xFF7DCEFB),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500)),
                            onPressed: _handleSaveSettings)
                      ],
                    )))),
        Column(
          children: [
            linearGradientLine(context, 3),
            Container(
                color: Color(0xFFF1F1F1),
                child: Row(
                  children: [
                    Padding(
                        padding: EdgeInsets.fromLTRB(10, 30, 0, 10),
                        child: Text("Account Settings",
                            style: TextStyle(
                                color: Color(0xFF5A5A5A),
                                fontSize: 16,
                                fontWeight: FontWeight.w400))),
                    Spacer()
                  ],
                )),
            Container(
                color: Colors.white,
                child: Column(
                  children: [
                    TextButton(
                        onPressed: _handleChangePhoneNumber,
                        child: Row(
                          children: [
                            Text("Phone Number",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16)),
                            Spacer(),
                            Text("$number",
                                style: TextStyle(
                                    color: Color(0xFF999999), fontSize: 16)),
                            Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Icon(Icons.arrow_forward_ios,
                                    color: Color(0xFF999999), size: 14))
                          ],
                        )),
                    Padding(
                        child: linearGradientLine(context, 1.5),
                        padding: EdgeInsets.only(left: 10)),
                    TextButton(
                        onPressed: _handleSocialMedia,
                        child: Row(
                          children: [
                            Text("Account Links",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16)),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios,
                                color: Color(0xFF999999), size: 14)
                          ],
                        )),
                    Padding(
                        child: linearGradientLine(context, 1.5),
                        padding: EdgeInsets.only(left: 10)),
                    TextButton(
                        onPressed: _handleChangeEmail,
                        child: Row(
                          children: [
                            Text("Email Address",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16)),
                            Spacer(),
                            Text("${_auth.currentUser!.email ?? ''}",
                                style: TextStyle(
                                    color: Color(0xFF999999), fontSize: 16)),
                            Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Icon(Icons.arrow_forward_ios,
                                    color: Color(0xFF999999), size: 14))
                          ],
                        )),
                  ],
                )),

            // account settings
            Column(
              children: [
                Container(
                    color: Color(0xFFF1F1F1),
                    child: Column(
                      children: [
                        Padding(
                            child: Text(
                                "A verified phone number and linking to social media can help secure your account.",
                                style: TextStyle(color: Color(0xFF5A5A5A))),
                            padding: EdgeInsets.fromLTRB(10, 5, 20, 10)),
                        Row(
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                child: Text("Discovery Settings",
                                    style: TextStyle(
                                        color: Color(0xFF5A5A5A),
                                        fontSize: 16))),
                            Spacer()
                          ],
                        ),
                      ],
                    )),
                Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 5),
                            child: TextButton(
                                onPressed: _handleLocation,
                                child: Row(
                                  children: [
                                    Text("Location",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16)),
                                    Spacer(),
                                    Row(
                                      children: [
                                        Text("Current location\nNew York, USA",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Color(0xFF999999),
                                                fontSize: 16)),
                                        Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Icon(Icons.arrow_forward_ios,
                                                color: Color(0xFF999999),
                                                size: 14))
                                      ],
                                    )
                                  ],
                                ))),
                        Padding(
                            child: linearGradientLine(context, 1.5),
                            padding: EdgeInsets.only(left: 10)),
                        Padding(
                            padding: EdgeInsets.only(left: 10, top: 20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text("Maximum Location",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16)),
                                    Spacer(),
                                    Padding(
                                        padding: EdgeInsets.only(right: 25),
                                        child: Text(
                                            "${_userData['location']['radius'].toInt()} mi.",
                                            style: TextStyle(
                                                color: Color(0xFF999999),
                                                fontSize: 16))),
                                  ],
                                ),
                                SliderTheme(
                                    data: SliderThemeData(
                                        thumbColor: Color(0xFFEEEEEE),
                                        activeTrackColor: Color(0xFFFA89A7),
                                        thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 15.0),
                                        inactiveTrackColor: Color(0xFFC9C9C9),
                                        activeTickMarkColor: Color(0xFFFA89A7),
                                        inactiveTickMarkColor:
                                            Color(0xFFC9C9C9)),
                                    child: Slider(
                                        value: _currentMaxLocation == 1
                                            ? _userData['location']['radius']
                                                .toDouble()
                                            : _currentMaxLocation,
                                        min: 1,
                                        max: 25,
                                        divisions: 25,
                                        onChangeEnd: _handleChangeMaxLocation,
                                        label: _currentMaxLocation
                                            .toInt()
                                            .toString(),
                                        onChanged: (double val) {
                                          setState(() {
                                            _currentMaxLocation = val;
                                          });
                                          var location = _userData['location'];
                                          location['radius'] = val.toInt();
                                          AppStateWidget.of(context)
                                              .updateUserData(
                                                  'location', location);
                                        }))
                              ],
                            )),
                      ],
                    ))
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Container(
                        width: size.width,
                        color: Color(0xFFF1F1F1),
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Text("Food Allergies",
                                style: TextStyle(
                                    color: Color(0xFF5A5A5A),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16)))),
                    Spacer()
                  ],
                ),
                Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        TextButton(
                            onPressed: _handleFoodAllergies,
                            child: Row(
                              children: [
                                Text("Add or remove allergies",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16)),
                                Spacer(),
                                Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Icon(Icons.arrow_forward_ios,
                                        color: Color(0xFF999999), size: 14))
                              ],
                            )),
                      ],
                    ))
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Container(
                        width: size.width,
                        color: Color(0xFFF1F1F1),
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Text("Read Receipts",
                                style: TextStyle(
                                    color: Color(0xFF5A5A5A),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16)))),
                    Spacer()
                  ],
                ),
                Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        TextButton(
                            onPressed: _handleReadReceipts,
                            child: Row(
                              children: [
                                Text("Manage Read Receipts",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16)),
                                Spacer(),
                                Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Icon(Icons.arrow_forward_ios,
                                        color: Color(0xFF999999), size: 14))
                              ],
                            )),
                      ],
                    ))
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Container(
                        width: size.width,
                        color: Color(0xFFF1F1F1),
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Text("Notifications",
                                style: TextStyle(
                                    color: Color(0xFF5A5A5A),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16)))),
                    Spacer()
                  ],
                ),
                Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        TextButton(
                            onPressed: _handleEmailNotifications,
                            child: Row(
                              children: [
                                Text("Email Notifications",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16)),
                                Spacer(),
                                Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Icon(Icons.arrow_forward_ios,
                                        color: Color(0xFF999999), size: 14))
                              ],
                            )),
                        Padding(
                            child: linearGradientLine(context, 1.5),
                            padding: EdgeInsets.only(left: 10)),
                        TextButton(
                            onPressed: _handlePushNotifications,
                            child: Row(
                              children: [
                                Text("Push Notifications",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16)),
                                Spacer(),
                                Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Icon(Icons.arrow_forward_ios,
                                        color: Color(0xFF999999), size: 14))
                              ],
                            )),
                      ],
                    ))
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Container(
                        width: size.width,
                        color: Color(0xFFF1F1F1),
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Text("System",
                                style: TextStyle(
                                    color: Color(0xFF5A5A5A),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16)))),
                    Spacer()
                  ],
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text("Dark Mode",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16)),
                                Spacer(),
                                Switch(
                                    value: darkMode,
                                    activeColor: Colors.white,
                                    activeTrackColor: Color(0xFFFC4F66),
                                    onChanged: (val) {
                                      _handleDarkMode(val);
                                    })
                              ],
                            ),
                          ],
                        )))
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Container(
                        width: size.width,
                        color: Color(0xFFF1F1F1),
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Text("Support",
                                style: TextStyle(
                                    color: Color(0xFF5A5A5A),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16)))),
                    Spacer()
                  ],
                ),
                Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        TextButton(
                            onPressed: _handleHelpSupport,
                            child: Row(
                              children: [
                                Text("Help & Support",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16)),
                                Spacer(),
                                Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Icon(Icons.arrow_forward_ios,
                                        color: Color(0xFF999999), size: 14))
                              ],
                            )),
                      ],
                    ))
              ],
            ),
            Container(height: 35, color: Color(0xFFF1F1F1)),

            Container(
                color: Colors.white,
                child: Column(
                  children: [
                    TextButton(
                      onPressed: _handleLogout,
                      child: Text("Logout",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 16)),
                    ),
                  ],
                )),
            Column(
              children: [
                Container(
                    color: Color(0xFFF1F1F1),
                    width: size.width,
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            child: Column(
                              children: [
                                Image.asset("images/Icons/HungerSwipeLogo.png"),
                                Text("Version 0.0.1")
                              ],
                            )),
                      ],
                    ))
              ],
            ),
            Container(
                color: Colors.white,
                child: Column(
                  children: [
                    TextButton(
                      onPressed: _handleDeleteAccount,
                      child: Text("Delete Account",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 16)),
                    ),
                  ],
                )),
          ],
        )
      ],
    ))));
  }
}
