import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/customIndicator.dart';
import 'package:hungerswipe/helpers/widgets/gradientButton.dart';
import 'package:hungerswipe/helpers/widgets/outlinedButton.dart';
import 'package:hungerswipe/screens/unauthorized/signup/phone_verification.dart';
import 'package:hungerswipe/screens/unauthorized/signup/username.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';

class FullName extends StatefulWidget {
  @override
  _FullNameState createState() => _FullNameState();
}

class _FullNameState extends State<FullName> {
  // bool isActive = false;
  late String firstName;
  late String lastName;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_handleInput);
    _lastNameController.addListener(_handleInput);
  }

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
  }

  void _handleInput() {
    setState(() {
      this.firstName = _firstNameController.text;
      this.lastName = _lastNameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    void _handleUpdate() {
      AppStateWidget.of(context).updateUserData("firstName", this.firstName);
      AppStateWidget.of(context).updateUserData("lastName", this.lastName);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => Username()));
    }

    var statusBarHeight = MediaQuery.of(context).padding.top;
    var width = MediaQuery.of(context).size.width;
    // final String current = AppStateScope.of(context).photoURL;
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
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        PhoneVerification()),
                                (route) => false);
                          },
                          icon: Icon(Icons.arrow_back_ios_new,
                              color: LightModeColors["primary"], size: 24.0)),
                      customIndicator(context, 15),
                      Container(width: 24),
                    ]),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text('Full Name',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold))),
                Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 5),
                    child:
                        //         child: Text(this.error != "" ? this.error : "",
                        //             style:
                        //                 TextStyle(color: Colors.red, fontSize: 14)))),
                        Container(
                            width: width / 1.2,
                            child: TextField(
                              controller: _firstNameController,
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
                              decoration: InputDecoration(
                                  filled: true,
                                  hintText: "First Name",
                                  hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal),
                                  fillColor: LightModeColors["inputColor"],
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(5))),
                            ))),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Container(
                        width: width / 1.2,
                        child: TextField(
                          controller: _lastNameController,
                          keyboardType: TextInputType.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          cursorColor: Colors.black26,
                          cursorHeight: 24,
                          // onChanged: (String? text) {
                          //   if (_firstNameController.text != "")
                          //     this.isActive = true;
                          // },
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              filled: true,
                              hintText: "Last Name",
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal),
                              fillColor: LightModeColors["inputColor"],
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(5))),
                        ))),
                Container(
                    width: 300,
                    child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "This is the name that others will see on your profile.",
                                style: TextStyle(
                                    color: LightModeColors["helperText"],
                                    fontSize: 12)),
                          ],
                        ))),
                Spacer(),
                Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: _firstNameController.text != "" &&
                            _lastNameController.text != ""
                        ? gradientButton(context, _handleUpdate, "Next")
                        : outlinedButton(context, 36))
              ],
            )));
  }
}
