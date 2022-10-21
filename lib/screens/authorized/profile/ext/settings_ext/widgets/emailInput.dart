import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/customIndicator.dart';
import 'package:hungerswipe/helpers/widgets/gradientButton.dart';
import 'package:hungerswipe/helpers/widgets/orderedInputBox.dart';
import 'package:hungerswipe/helpers/widgets/outlinedButton.dart';
import 'package:hungerswipe/screens/loading.dart';
import 'package:hungerswipe/screens/unauthorized/signup/profile_photo.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';

class EmailInput extends StatefulWidget {
  @override
  _EmailInputState createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  // bool isActive = false;
  late String emailInput;
  bool error = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailInputController = TextEditingController();
  bool isActive = false;
  bool loading = false;
  bool verification = false;
  bool pendingVerification = false;
  late String _verificationId;
  late PhoneAuthCredential _phoneAuthCredential;
  String verifyError = "";
  final controllers = {
    0: TextEditingController(),
    1: TextEditingController(),
    2: TextEditingController(),
    3: TextEditingController(),
    4: TextEditingController(),
    5: TextEditingController(),
  };
  @override
  void initState() {
    super.initState();
    _emailInputController.addListener(_handleInput);
  }

  @override
  void dispose() {
    super.dispose();
    _emailInputController.dispose();
    controllers.forEach((key, value) => value.dispose());
  }

  void _handleInput() {
    setState(() {
      this.emailInput = _emailInputController.text;
      bool _valid = EmailValidator.validate(_emailInputController.text);
      this.error = !_valid;
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

  void verificationCompleted(PhoneAuthCredential credential) async {
    this._phoneAuthCredential = credential;
  }

  void verificationFailed(FirebaseAuthException exception) async {
    _handleError(exception);
  }

  void _handleError(FirebaseAuthException exception) {
    print('error received -- ${exception.code}');
    setState(() {
      this.loading = false;
      switch (exception.code) {
        case "invalid-verification-code":
          this.verifyError =
              "Invalid verification code entered. Please try again.";
          controllers.forEach((key, value) {
            value.clear();
          });
          break;
      }
    });
  }

  void _onChanged() {
    setState(() {
      this.verifyError = "";
    });
  }

  Future<void> _continueSignIn() async {
    try {
      var user = await _auth.signInWithCredential(this._phoneAuthCredential);
      if (user.user != null) {
        AppStateWidget.of(context).updateUserData("email", this.emailInput);
        user.user!.updateEmail(this.emailInput);
        Navigator.of(context).pop();
      }
      setState(() {
        this.loading = false;
      });
    } on FirebaseAuthException catch (e) {
      print('got an error. handling. ${e.code}');
      _handleError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var userData = AppStateScope.of(context).userData;
    void _handleUpdate() async {
      if (!pendingVerification) {
        setState(() {
          pendingVerification = true;
        });
        await _auth.verifyPhoneNumber(
            timeout: Duration(milliseconds: 0),
            phoneNumber: userData['phoneNumber'],
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
      } else {
        if (this.verifyError == "") {
          String smsCode =
              '${controllers[0]?.text}${controllers[1]?.text}${controllers[2]?.text}${controllers[3]?.text}${controllers[4]?.text}${controllers[5]?.text}';
          this._phoneAuthCredential = PhoneAuthProvider.credential(
              verificationId: this._verificationId, smsCode: smsCode);
          _continueSignIn();
        } else
          print('error received.');
      }
    }

    var statusBarHeight = MediaQuery.of(context).padding.top;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
            padding: EdgeInsets.only(top: statusBarHeight),
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
                      customIndicator(context, pendingVerification ? 52 : 30),
                      Container(width: 24),
                    ]),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text(
                        pendingVerification
                            ? "Verification Code"
                            : 'Email Address',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold))),
                Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 5),
                    child: pendingVerification
                        ? Column(children: [
                            Container(
                                child: Text(
                                    this.verifyError != ""
                                        ? this.verifyError
                                        : "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 14))),
                            FocusTraversalGroup(
                                policy: OrderedTraversalPolicy(),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children:
                                      List<Widget>.generate(6, (int index) {
                                    return OrderedInputBox<num>(
                                        order: index,
                                        controller: controllers[index],
                                        onChanged: _onChanged);
                                  }),
                                )),
                          ])
                        : Container(
                            width: width / 1.2,
                            height: 70,
                            child: TextField(
                              controller: _emailInputController,
                              keyboardType: TextInputType.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                              cursorColor: Colors.black26,
                              cursorHeight: 24,
                              // onChanged: (String? text) {
                              //   if (_lastNameController.text != "")
                              //     this.isActive = true;
                              // },
                              textAlign: TextAlign.center,
                              enableSuggestions: true,
                              decoration: InputDecoration(
                                  filled: true,
                                  errorText: this.error ? "Invalid Email" : "",
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 0.2)),
                                  hintText: "Email address",
                                  hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal),
                                  fillColor: LightModeColors["inputColor"],
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(5))),
                            ))),
                pendingVerification
                    ? Column(
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
                                          color: LightModeColors["helperText"],
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
                                                  begin: Alignment(0, 0),
                                                  end: Alignment(1.0, 4),
                                                  colors: [
                                                    LightModeColors["blue"]
                                                        ["gradient1"],
                                                    LightModeColors["blue"]
                                                        ["gradient2"],
                                                  ],
                                                  stops: [
                                                    -.3295,
                                                    2.1969,
                                                  ]),
                                              borderRadius:
                                                  BorderRadius.circular(36.0),
                                              border: Border.all(
                                                  width: 0,
                                                  color: Colors.transparent),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.01),
                                                  spreadRadius: 1,
                                                  blurRadius: 10,
                                                  offset: Offset(0, 0),
                                                )
                                              ]),
                                          child: TextButton(
                                            onPressed: () {},
                                            child: Text("Resend",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                textAlign: TextAlign.center),
                                          )))
                                ],
                              ))
                        ],
                      )
                    : Container(
                        width: 300,
                        child: Padding(
                            padding: EdgeInsets.only(top: 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    "Link a new email address to your account. An SMS verification code may be sent to the number associated with your account.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: LightModeColors["helperText"],
                                        fontSize: 12)),
                              ],
                            ))),
                Spacer(),
                Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: _emailInputController.text != "" && !this.error ||
                            (!this.pendingVerification &&
                                    controllers[0]?.text != "" ||
                                controllers[0]?.text != null)
                        ? gradientButton(context, _handleUpdate, "Next")
                        : outlinedButton(context, 36))
              ],
            )));
  }
}
