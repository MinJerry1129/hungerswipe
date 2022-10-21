import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/customIndicator.dart';
import 'package:hungerswipe/helpers/widgets/gradientButton.dart';
import 'package:hungerswipe/helpers/widgets/orderedInputBox.dart';
import 'package:hungerswipe/helpers/widgets/outlinedButton.dart';
import 'package:hungerswipe/screens/unauthorized/signup/fullname.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';

class PhoneVerification extends StatefulWidget {
  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  bool isActive = false;
  bool loading = false;
  String countryCode = "+1";
  late String phoneNumber = "";
  bool verification = false;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      this.loading = false;
      this.verification = true;
      this._verificationId = verificationId;
      // this._code = code ?? 0;
    });
  }

  Future<void> _continueRegistration() async {
    try {
      var user =
          await _firebaseAuth.signInWithCredential(this._phoneAuthCredential);
      if (user.user != null) {
        _firestore
            .collection("users")
            .doc(phoneNumber)
            .set({"phoneNumber": phoneNumber});

        AppStateWidget.of(context).updateUserData("phoneNumber", phoneNumber);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => FullName()),
            (route) => false);
      }
      setState(() {
        this.loading = false;
      });
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
    setState(() {
      this.loading = true;
    });
    await _firestore
        .collection("users")
        .doc(phoneNumber)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        print('doc exists...');
        setState(() {
          this.loading = false;
          this.error = "An account with that phone number already exists.";
        });
      }
    });

    if (this.error == "") {
      if (!verification) {
        await _firebaseAuth.verifyPhoneNumber(
            timeout: Duration(milliseconds: 0),
            phoneNumber: phoneNumber,
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
      } else {
        print('exist verification.');
        String smsCode =
            '${controllers[0]?.text}${controllers[1]?.text}${controllers[2]?.text}${controllers[3]?.text}${controllers[4]?.text}${controllers[5]?.text}';
        this._phoneAuthCredential = PhoneAuthProvider.credential(
            verificationId: this._verificationId, smsCode: smsCode);
        _continueRegistration();
      }
    } else
      print('error received.');
  }

  void _handleError(FirebaseAuthException exception) {
    print('error received -- ${exception.code}');
    setState(() {
      this.loading = false;
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
      this.loading = true;
    });
    if(controllers[0]?.text != null && controllers[1]?.text != null && controllers[2]?.text != null && controllers[3]?.text != null && controllers[4]?.text != null && controllers[5]?.text != null){
      if(controllers[0]?.text != "" && controllers[1]?.text != "" && controllers[2]?.text != "" && controllers[3]?.text != "" && controllers[4]?.text != "" && controllers[5]?.text != ""){        
        if (!verification) {
          await _firebaseAuth.verifyPhoneNumber(
              timeout: Duration(milliseconds: 0),
              phoneNumber: phoneNumber,
              verificationCompleted: verificationCompleted,
              verificationFailed: verificationFailed,
              codeSent: codeSent,
              codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
        } else {
          print('exist verification.');
          String smsCode =
              '${controllers[0]?.text}${controllers[1]?.text}${controllers[2]?.text}${controllers[3]?.text}${controllers[4]?.text}${controllers[5]?.text}';
          this._phoneAuthCredential = PhoneAuthProvider.credential(
              verificationId: this._verificationId, smsCode: smsCode);
          _continueRegistration();
        }
      }
    }
    
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
                      customIndicator(context, verification ? 10 : 5),
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
                this.loading ? CircularProgressIndicator() : SizedBox.shrink(),
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
