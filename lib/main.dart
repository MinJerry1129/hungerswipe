// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/screens/authorized/messages/newmessage.dart';
import 'package:hungerswipe/screens/authorized/messages/thread.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/notifications.dart';
// import 'package:hungerswipe/helpers/swatchGenerator.dart';
// import 'package:hungerswipe/screens/authorized/home/home.dart';
import 'package:hungerswipe/screens/authorized/tab_controller/tab_controller.dart';
import 'package:hungerswipe/screens/unauthorized/signup_login.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _backgroundMessagingHandler(RemoteMessage message) async {
  print(
      'backgroundMessageInfoHandlerStuffThings ${message.data} ${message.messageType}');
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Phoenix(child: HungerSwipe()));
  FirebaseMessaging.onBackgroundMessage(_backgroundMessagingHandler);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  ));
}

class HungerSwipe extends StatefulWidget {
  @override
  _HungerSwipeState createState() => _HungerSwipeState();
}

class _HungerSwipeState extends State<HungerSwipe> {
  bool _init = false;
  bool _err = false;
  bool _isDark = false;

  void initFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _init = true;
      });
    } catch (e) {
      setState(() {
        _err = true;
      });
    }
  }

  void initDarkMode() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    print(_prefs.getBool("darkMode"));
    if (_prefs.getBool("darkMode") == true) {
      setState(() {
        _isDark = true;
      });
    }
  }

  @override
  void initState() {
    initFire();
    initDarkMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CupertinoThemeData _light = CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        primaryContrastingColor: Color(0xFF7DCEFB),
        textTheme:
            CupertinoTextThemeData(textStyle: TextStyle(color: Colors.black)));

    CupertinoThemeData _dark = CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        primaryContrastingColor: Color(0xFF7DCEFB),
        textTheme:
            CupertinoTextThemeData(textStyle: TextStyle(color: Colors.white)));

    return AppStateWidget(
        child: CupertinoApp(
      routes: {
        "/newMessage": (context) => NewMessage(),
        "/thread": (context) =>
            Thread(args: ModalRoute.of(context)!.settings.arguments),
        // "/groupSwipe": (context) => GroupSwipe()
      },
      debugShowCheckedModeBanner: false,
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      title: 'HungerSwipe',
      theme: _isDark ? _dark : _light,
      home: Scaffold(
          body: _err
              ? splashScreen()
              : !_init
                  ? splashScreen()
                  : SplashScreen()),
    ));

    // MaterialApp(
    //     title: "HungerSwipe",
    //     darkTheme: _dark,
    //     theme: _light,
    //     themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
    //     debugShowCheckedModeBanner: false,
    //     home: ));
  }
}

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var currentUser;
  // late final UserModel userModel;
  bool isAuthenticated = false;
  _isUserSignedIn() async {
    currentUser = _auth.currentUser;
    // get user db info
    if (currentUser != null) {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      final FirebaseMessaging _messaging = FirebaseMessaging.instance;
      var snapshot = _firestore.collection("restaurants").snapshots();
      var toMiles = (meters) => meters / 1609.344;
      var _userData = await _firestore
          .collection("users")
          .doc(_auth.currentUser!.phoneNumber)
          .get();
      String? _token = await _messaging.getToken();

      await _firestore
          .collection("users")
          .doc(_auth.currentUser!.phoneNumber)
          .get()
          .then((doc) {
        var data = doc.data();
        if (data!.containsKey("tokens")) {
          List tokens = data['tokens'];
          if (tokens.contains(_token))
            return;
          else {
            doc.reference.update({
              "tokens": FieldValue.arrayUnion([_token])
            });
          }
        } else {
          doc.reference.update({
            "tokens": [_token]
          });
        }
      });
      snapshot.forEach((stream) {
        var docs = stream.docs;
        docs.forEach((restaurant) {
          var data = restaurant.data();
          print('pls $data');
          var _restaurantItem = restaurant.data();
          var lat = _userData['location']['latitude'];
          var lng = _userData['location']['longitude'];
          var lat2 = data['lat'];
          var lng2 = data['lng'];
          var radius = _userData['location']['radius'];
          double distance = Geolocator.distanceBetween(lat2, lng2, lat, lng);
          var adjustedDistance = toMiles(distance);
          if (adjustedDistance.toInt() <= radius) {
            AppStateWidget.of(context).addRestaurant(_restaurantItem);
          }
        });
      });
      _firestore
          .collection('users')
          .doc(currentUser.phoneNumber)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        Map<String, dynamic> _data =
            documentSnapshot.data() as Map<String, dynamic>;
        if (_data['modePreference'] == "dark-mode") {
          await _prefs.setBool("darkMode", true);
        } else {
          await _prefs.setBool("darkMode", false);
        }
        AppStateWidget.of(context).updateAllUserData(_data);
      });
    }
    setState(() {
      currentUser != null ? isAuthenticated = true : isAuthenticated = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _isUserSignedIn();
    startTime();
  }

  startTime() async {
    var _duration = new Duration(seconds: 4);
    return new Timer(_duration, navPage);
  }

  Widget userAuthState() {
    if (!isAuthenticated) {
      return SignupOrLogin();
    } else {
      return Tabs();
    }
  }

  void _handleMessage(RemoteMessage message) {
    print('handling a message. $message');
    var type = message.data['type'];

    if (type.split(":")[0] == "friend-request") {
      Navigator.push(
          context,
          MaterialPageRoute(
              fullscreenDialog: true,
              builder: (BuildContext context) => NotificationsScreen()));
    }
  }

  Future<void> navPage() async {
    FirebaseMessaging _messaging = FirebaseMessaging.instance;
    RemoteMessage? _message = await _messaging.getInitialMessage();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => userAuthState()));
    if (_message != null) _handleMessage(_message);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  @override
  Widget build(BuildContext context) {
    return splashScreen();
  }
}

Widget splashScreen() {
  return Scaffold(
      backgroundColor: LightModeColors["primary"],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: Image(
                image: AssetImage("images/Icons/hungerswipe_logowhite.png"),
                fit: BoxFit.contain,
                width: 300,
                height: 250),
          ),
        ],
      ));
}
