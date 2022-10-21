import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/customIndicator.dart';
import 'package:hungerswipe/helpers/widgets/gradientButton.dart';
import 'package:hungerswipe/helpers/widgets/orderedInputBox.dart';
import 'package:hungerswipe/helpers/widgets/outlinedButton.dart';
import 'package:hungerswipe/screens/authorized/home/home.dart';
import 'package:hungerswipe/screens/authorized/tab_controller/tab_controller.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isActive = false;
  String countryCode = "+1";
  late String phoneNumber = "";
  bool verification = false;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseMessaging _messaging = FirebaseMessaging.instance;

  late String error = "";
  // late int _code;
  late String _verificationId;
  late PhoneAuthCredential _phoneAuthCredential;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleInput);
  }

  @override
  void dispose() {
    _controller.dispose();
    controllers.forEach((key, value) => value.dispose());
    super.dispose();
  }

  final _controller = TextEditingController();
  final controllers = {
    0: TextEditingController(),
    1: TextEditingController(),
    2: TextEditingController(),
    3: TextEditingController(),
    4: TextEditingController(),
    5: TextEditingController(),
  };

  void _handleInput() {
    setState(() {
      phoneNumber = '$countryCode${_controller.text}';
    });
  }

  void _handleCountry(CountryCode code) {
    setState(() {
      countryCode = code.toString();
    });
  }

  void codeAutoRetrievalTimeout(String verificationId) {
    print('code auto-retrieval timeout');
    print(verificationId);
  }

  void codeSent(String verificationId, int? code) {
    setState(() {
      this.verification = true;
      this._verificationId = verificationId;
      // this._code = code ?? 0;
    });
  }

  Future<void> _login() async {
    try {
      var user =
          await _firebaseAuth.signInWithCredential(this._phoneAuthCredential);
      if (user.user != null) {
        // FIXME: NEED TO GET USER'S DATA FROM FIREBASE HERE.
        // FIXME: NEED TO CHECK IF USER EXISTS OR NOT. MUST DO THIS BEFORE THIS LOGIN METHOD IS RAN.
        // why do we need to do that jalon
        // we should convert the below code to be a callable snippet for both main.dart and here (post-beta stuff)
        var currentUser = user.user;
        // get user db info
        if (currentUser != null) {
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          var snapshot = _firestore.collection("restaurants").snapshots();
          var toMiles = (meters) => meters / 1609.344;
          var _userData = await _firestore
              .collection("users")
              .doc(currentUser.phoneNumber)
              .get();
          String? _token = await _messaging.getToken();

          await _firestore
              .collection("users")
              .doc(currentUser.phoneNumber)
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
              double distance =
                  Geolocator.distanceBetween(lat2, lng2, lat, lng);
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
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => Tabs()),
            (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      print('got an error. handling. ${e.code}');
      _handleError(e);
    }
  }

  void verificationCompleted(PhoneAuthCredential credential) async {
    this._phoneAuthCredential = credential;
  }

  void verificationFailed(FirebaseAuthException exception) async {
    _handleError(exception);
  }

  void _submitPressed() async {
    if (!verification) {
      await _firebaseAuth.verifyPhoneNumber(
          timeout: Duration(milliseconds: 0),
          phoneNumber: phoneNumber,
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } else {
      String smsCode =
          '${controllers[0]?.text}${controllers[1]?.text}${controllers[2]?.text}${controllers[3]?.text}${controllers[4]?.text}${controllers[5]?.text}';
      this._phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: this._verificationId, smsCode: smsCode);
      _login();
    }
  }

  void _handleError(FirebaseAuthException exception) {
    print('error received -- ${exception.code}');
    setState(() {
      switch (exception.code) {
        case "too-many-requests":
          this.error =
              "You are doing that too quickly. Please try again later.";
          _controller.clear();
          break;
        case "invalid-phone-number":
          this.error = "Invalid phone number received. Please try again.";
          _controller.clear();
          break;
        case "invalid-verification-code":
          this.error = "Invalid verification code entered. Please try again.";
          controllers.forEach((key, value) {
            value.clear();
          });
          break;
        case "user-disabled":
          this.error = "Your account has been disabled.";
          _controller.clear();
          break;
      }
    });
  }

  void _onChanged() {
    setState(() {
      this.error = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.top;
    // var screenWidth = MediaQuery.of(context).size.width;

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
                            if (verification)
                              setState(() {
                                verification = false;
                              });
                            else
                              Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios_new,
                              color: LightModeColors["primary"], size: 24.0)),
                      customIndicator(context, verification ? 54.5 : 30),
                      Container(width: 24),
                    ]),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text(
                        '${verification ? "Verification Code" : "Phone Number"}',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold))),
                Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 5),
                    child: Container(
                        child: Text(this.error != "" ? this.error : "",
                            style:
                                TextStyle(color: Colors.red, fontSize: 14)))),
                !verification
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  color: LightModeColors["inputColor"],
                                  borderRadius: BorderRadius.circular(5)),
                              child: CountryCodePicker(
                                  onChanged: (countryCode) =>
                                      _handleCountry(countryCode),
                                  initialSelection: "US")),
                          Container(width: 30),
                          Container(
                              width: 200,
                              child: TextField(
                                controller: _controller,
                                keyboardType: TextInputType.phone,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                                cursorColor: Colors.black26,
                                cursorHeight: 24,
                                onChanged: (String? text) {
                                  this.error = "";
                                },
                                decoration: InputDecoration(
                                    prefixText: countryCode,
                                    prefixStyle: TextStyle(fontSize: 0),
                                    filled: true,
                                    fillColor: LightModeColors["inputColor"],
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(5))),
                              ))
                        ],
                      )
                    : FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List<Widget>.generate(6, (int index) {
                            return OrderedInputBox<num>(
                                order: index,
                                controller: controllers[index],
                                onChanged: _onChanged);
                          }),
                        )),
                Container(
                    width: 300,
                    child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: !verification
                            ? RichText(
                                text: TextSpan(children: [
                                TextSpan(
                                  text:
                                      "We will send an SMS with a verification code. Message and data rates may apply. ",
                                  style: TextStyle(
                                      color: LightModeColors["helperText"],
                                      fontSize: 12),
                                ),
                                TextSpan(
                                  text:
                                      "Learn what happens when your number changes.",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.black,
                                      fontSize: 12),
                                )
                              ]))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "Please enter the 6 digit sms code you received.",
                                      style: TextStyle(
                                          color: LightModeColors["helperText"],
                                          fontSize: 12)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 35),
                                      child: Column(
                                        children: [
                                          Text("Didn’t receive the code?",
                                              style: TextStyle(
                                                  color: LightModeColors[
                                                      "helperText"],
                                                  fontSize: 12)),
                                          Padding(
                                              padding: EdgeInsets.only(top: 10),
                                              child: Container(
                                                  width: 75,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      // when active
                                                      gradient: LinearGradient(
                                                          begin:
                                                              Alignment(0, 0),
                                                          end:
                                                              Alignment(1.0, 4),
                                                          colors: [
                                                            LightModeColors[
                                                                    "blue"]
                                                                ["gradient1"],
                                                            LightModeColors[
                                                                    "blue"]
                                                                ["gradient2"],
                                                          ],
                                                          stops: [
                                                            -.3295,
                                                            2.1969,
                                                          ]),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              36.0),
                                                      border: Border.all(
                                                          width: 0,
                                                          color: Colors
                                                              .transparent),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.01),
                                                          spreadRadius: 1,
                                                          blurRadius: 10,
                                                          offset: Offset(0, 0),
                                                        )
                                                      ]),
                                                  child: TextButton(
                                                    onPressed: _submitPressed,
                                                    child: Text("Resend",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                        textAlign:
                                                            TextAlign.center),
                                                  )))
                                        ],
                                      ))
                                ],
                              ))),
                Spacer(),
                Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child:
                        phoneNumber.length > 2 || controllers[0]?.text != null
                            ? gradientButton(context, _submitPressed, "Next")
                            : outlinedButton(context, 36))
              ],
            )));
  }
}
