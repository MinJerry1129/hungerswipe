import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/screens/unauthorized/login/login.dart';
import 'package:hungerswipe/screens/unauthorized/signup/phone_verification.dart';

class SignupOrLogin extends StatefulWidget {
  @override
  _SignupOrLoginState createState() => _SignupOrLoginState();
}

class _SignupOrLoginState extends State<SignupOrLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFA89A7),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
                padding: EdgeInsets.all(50),
                child: Image(
                    image:
                        AssetImage("images/Icons/hungerswipe_logowhite.png"))),
            Container(
                width: MediaQuery.of(context).size.width / 1.3,
                child: Text(
                  "By tapping Create Account or Sign In, you agree to our Terms. Learn how we process your data in Privacy Policy and Cookies Policy.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFFFCFC),
                  ),
                  textAlign: TextAlign.left,
                )),
            Padding(
                padding: EdgeInsets.only(top: 50),
                child: Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36.0),
                        border: Border.all(width: 0, color: Colors.transparent),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          )
                        ]),
                    child: TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  PhoneVerification())),
                      child: Text("Create Account",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ))),
            Padding(
                padding: EdgeInsets.only(top: 30),
                child: Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              LightModeColors["gradient1"],
                              LightModeColors["gradient2"],
                            ],
                            stops: [
                              0.2765,
                              1
                            ]),
                        borderRadius: BorderRadius.circular(36.0),
                        border: Border.all(width: 0, color: Colors.transparent),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          )
                        ]),
                    child: TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => Login())),
                      child: Text("Sign In",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ))),
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                "Trouble signing in?",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFFFFCFC),
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ));
  }
}
