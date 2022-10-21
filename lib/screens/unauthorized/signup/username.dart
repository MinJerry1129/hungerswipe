import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/customIndicator.dart';
import 'package:hungerswipe/helpers/widgets/gradientButton.dart';
import 'package:hungerswipe/helpers/widgets/outlinedButton.dart';
import 'package:hungerswipe/screens/unauthorized/signup/profile_photo.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';

class Username extends StatefulWidget {
  @override
  _UsernameState createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  // bool isActive = false;
  late String username;

  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_handleInput);
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
  }

  void _handleInput() {
    setState(() {
      this.username = _usernameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    void _handleUpdate() {
      AppStateWidget.of(context).updateUserData("username", this.username);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => ProfilePhoto()));
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
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back_ios_new,
                              color: LightModeColors["primary"], size: 24.0)),
                      customIndicator(context, 25),
                      Container(width: 24),
                    ]),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text('Username',
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
                              controller: _usernameController,
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
                                  hintText: "Username",
                                  prefix: Text(
                                    "@",
                                  ),
                                  prefixStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                            Text("You can change your username at any time.",
                                style: TextStyle(
                                    color: LightModeColors["helperText"],
                                    fontSize: 12)),
                          ],
                        ))),
                Spacer(),
                Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: _usernameController.text != ""
                        ? gradientButton(context, _handleUpdate, "Next")
                        : outlinedButton(context, 36))
              ],
            )));
  }
}
