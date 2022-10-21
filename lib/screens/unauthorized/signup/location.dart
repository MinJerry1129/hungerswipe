import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/customIndicator.dart';
import 'package:hungerswipe/helpers/widgets/gradientButton.dart';
import 'package:hungerswipe/helpers/widgets/swipeCard.dart';
import 'package:hungerswipe/screens/loading.dart';
import 'package:hungerswipe/screens/unauthorized/signup/notification.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' show Client;

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  bool isActive = false;
  bool loading = false;
  FirebaseFunctions _functions = FirebaseFunctions.instance;
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
    // Client client = Client();
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    // final Map _userData = AppStateScope.of(context).userData;

    var statusBarHeight = MediaQuery.of(context).padding.top;
    var width = MediaQuery.of(context).size.width;

    Future<Position> _getLocation() async {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }
      return await Geolocator.getCurrentPosition();
    }

    Future<void> _handleUpdate() async {
      if (await Permission.location.request().isGranted) {
        Position position = await _getLocation();
        Map location = {
          "latitude": position.latitude,
          "longitude": position.longitude,
          "radius": 10,
        };
        Navigator.push(
            context,
            MaterialPageRoute(
                fullscreenDialog: true,
                builder: (BuildContext context) => LoadingDialog(
                    "Please wait while we gather restaurants near you.")));
        HttpsCallable callable = _functions.httpsCallable("getRestaurants");
        final res = await callable.call({
          "lat": position.latitude,
          "lng": position.longitude,
          "radius": 10,
        });

        final parsedJson = jsonDecode(res.data);
        List _data = parsedJson;
        print('restaurants here $_data');
        AppStateWidget.of(context).updateRestaurants(_data);

        AppStateWidget.of(context).updateUserData("location", location);
        await _firestore
            .collection("users")
            .doc(_userData["phoneNumber"])
            .update({
          "username": _userData["username"],
          "location": _userData["location"],
          "profilePhoto": _userData["profilePhoto"],
          "dateJoined": DateTime.now(),
          "lastActive": DateTime.now(),
          "firstName": _userData["firstName"],
          "lastName": _userData["lastName"],
        });
        AppStateWidget.of(context).updateAllUserData({
          "username": _userData["username"],
          "location": _userData["location"],
          "profilePhoto": _userData["profilePhoto"],
          "dateJoined": DateTime.now(),
          "lastActive": DateTime.now(),
          "firstName": _userData["firstName"],
          "lastName": _userData["lastName"],
        });
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => Notifications()));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => Notifications()));
      }
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
                    child: Text('Location Services',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold))),
                Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Container(
                      width: width / 1.5,
                      height: 300,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage(
                                  "images/Icons/location_ellipse.png"))),
                    )),
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Container(
                        width: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "Enabling your location will allow us to locate restaurants near you.",
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
                        onPressed: () => {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      Notifications()))
                            },
                        child: Text("Not Now",
                            style: TextStyle(color: Colors.grey))))
              ],
            )));
  }
}
