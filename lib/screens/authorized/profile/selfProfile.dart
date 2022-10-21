import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/gradientIcon.dart';
import 'package:hungerswipe/helpers/widgets/scrollableChips.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/editprofile.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/notifications.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/settings.dart'
    as SettingsScreen;
import 'package:hungerswipe/services/app_state/app_state.dart';

class SelfProfile extends StatefulWidget {
  final Map? _userData;
  final List favorites;
  const SelfProfile(this._userData, this.favorites);
  @override
  _SelfProfileState createState() => _SelfProfileState();
}

// Widget selfProfile(BuildContext context, Map _userData, favorites) {
class _SelfProfileState extends State<SelfProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool friends = false;
  bool pending = false;
  int friendCount = 0;
  int matchCount = 0;

  Future<void> _getStatCount() async {
    var _friends =
        _firestore.collection("friends").doc(_auth.currentUser!.phoneNumber);
    await _friends.collection("active").get().then((snapshot) {
      if (snapshot.docs.isNotEmpty)
        setState(() {
          friendCount = snapshot.docs.length;
        });
    });
  }

  @override
  initState() {
    super.initState();
    _getStatCount();
  }

  @override
  Widget build(BuildContext context) {
    var _userData = AppStateScope.of(context).userData;
    var size = MediaQuery.of(context).size;
    return SafeArea(
        child: Container(
            alignment: Alignment.topCenter,
            // main column -- houses the entire screen
            child: SingleChildScrollView(
                child: Column(
              children: [
                // TODO: first row -- houses profile photo, match count and friend count

                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: LayoutBuilder(
                                builder: (context, constraints) => Container(
                                    height: constraints.constrainHeight(100),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(colors: [
                                          Color(0xE0F169B6),
                                          Color(0xDAF3B3D6),
                                          Color(0xD37DCFFB),
                                        ])),
                                    child: Padding(
                                        padding: EdgeInsets.all(2.5),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle),
                                            child: Padding(
                                                padding: EdgeInsets.all(2.5),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: _userData[
                                                                  'profilePhoto']
                                                              .isNotEmpty
                                                          ? NetworkImage(
                                                              _userData[
                                                                  'profilePhoto'])
                                                          : AssetImage(
                                                                  "images/Icons/no-user.jpg")
                                                              as ImageProvider,
                                                      fit: BoxFit.fitWidth),
                                                  shape: BoxShape.circle,
                                                )))))))),
                        Expanded(
                            child: Column(
                          children: [
                            AutoSizeText(matchCount.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18)),
                            AutoSizeText(
                              "Matches",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        )),
                        Expanded(
                            child: Column(
                          children: [
                            AutoSizeText(friendCount.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18)),
                            AutoSizeText(
                              "Friends",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        )),
                      ],
                    )),
                // this column houses the user's first, last name and username
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.centerLeft,
                            child: AutoSizeText(
                                '${_userData["firstName"]} ${_userData["lastName"]}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18))),
                        Container(
                            alignment: Alignment.centerLeft,
                            child: AutoSizeText(('@${_userData["username"]}'),
                                style: TextStyle(color: Color(0xFF999999))))
                      ],
                    )),
                // TODO: user bio
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.centerLeft,
                            child: AutoSizeText('Bio',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16))),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(_userData['bio'] == null
                              ? "You don't have a bio yet. Type something interesting!"
                              : _userData['bio']),
                        ),
                      ],
                    )),
                // TODO: profile management buttons (edit profile, notifications, settings)
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Container(
                                height: constraints.constrainHeight(35),
                                width: constraints
                                    .constrainWidth(size.width * .25),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Color(0xFFC4C4C4), width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        spreadRadius: -5,
                                        blurRadius: 10,
                                        offset: Offset(2, 1),
                                      )
                                    ]),
                                child: Padding(
                                    child: TextButton(
                                        onPressed: () => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                fullscreenDialog: true,
                                                builder: (BuildContext context) => EditProfile(
                                                    name:
                                                        '${_userData["firstName"]} ${_userData["lastName"]}',
                                                    username:
                                                        _userData['username'],
                                                    bio: _userData['bio'] != null
                                                        ? _userData['bio']
                                                        : ""))),
                                        child: AutoSizeText("Edit Profile",
                                            style:
                                                TextStyle(color: Colors.black))),
                                    padding: EdgeInsets.symmetric(horizontal: 5)));
                          },
                        ),
                        LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Container(
                                height: constraints.constrainHeight(35),
                                width: constraints
                                    .constrainWidth(size.width * .25),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Color(0xFFC4C4C4), width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        spreadRadius: -5,
                                        blurRadius: 10,
                                        offset: Offset(2, 1),
                                      )
                                    ]),
                                child: Padding(
                                    child: TextButton(
                                        onPressed: () => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                fullscreenDialog: true,
                                                builder:
                                                    (BuildContext context) =>
                                                        NotificationsScreen())),
                                        child: AutoSizeText("Notifications",
                                            style: TextStyle(
                                                color: Colors.black))),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5)));
                          },
                        ),
                        LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Container(
                                height: constraints.constrainHeight(35),
                                width: constraints
                                    .constrainWidth(size.width * .25),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Color(0xFFC4C4C4), width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        spreadRadius: -5,
                                        blurRadius: 10,
                                        offset: Offset(2, 1),
                                      )
                                    ]),
                                child: Padding(
                                    child: TextButton(
                                        onPressed: () => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                fullscreenDialog: true,
                                                builder: (BuildContext
                                                        context) =>
                                                    SettingsScreen.Settings())),
                                        child: AutoSizeText("Settings",
                                            style: TextStyle(
                                                color: Colors.black))),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5)));
                          },
                        ),
                      ],
                    )),
                // TODO: user stories (essentially pictures they upload for friends to see)
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        // column will hold a preview of the story + story title (are we going to have them use an icon?? or??)
                        children: [
                          LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return Column(
                                children: [
                                  Container(
                                      height: constraints.constrainHeight(70),
                                      width: constraints
                                          .constrainWidth(size.width * .25),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: .4),
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Container(
                                              decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: _userData['profilePhoto']
                                                        .isNotEmpty
                                                    ? NetworkImage(_userData[
                                                        'profilePhoto'])
                                                    : AssetImage(
                                                            "images/Icons/no-user.jpg")
                                                        as ImageProvider,
                                                fit: BoxFit.cover),
                                            shape: BoxShape.circle,
                                          )))),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: AutoSizeText("New"))
                                ],
                              );
                            },
                          ),
                          LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return Column(
                                children: [
                                  Container(
                                      height: constraints.constrainHeight(70),
                                      width: constraints
                                          .constrainWidth(size.width * .25),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: .4),
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Container(
                                              decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: _userData['profilePhoto']
                                                        .isNotEmpty
                                                    ? NetworkImage(_userData[
                                                        'profilePhoto'])
                                                    : AssetImage(
                                                            "images/Icons/no-user.jpg")
                                                        as ImageProvider,
                                                fit: BoxFit.cover),
                                            shape: BoxShape.circle,
                                          )))),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: AutoSizeText("New"))
                                ],
                              );
                            },
                          ),
                          LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return Column(
                                children: [
                                  Container(
                                      height: constraints.constrainHeight(70),
                                      width: constraints
                                          .constrainWidth(size.width * .25),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: .4),
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Container(
                                              decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: _userData['profilePhoto']
                                                        .isNotEmpty
                                                    ? NetworkImage(_userData[
                                                        'profilePhoto'])
                                                    : AssetImage(
                                                            "images/Icons/no-user.jpg")
                                                        as ImageProvider,
                                                fit: BoxFit.cover),
                                            shape: BoxShape.circle,
                                          )))),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: AutoSizeText("New"))
                                ],
                              );
                            },
                          ),
                          LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return Column(
                                children: [
                                  Container(
                                      height: constraints.constrainHeight(70),
                                      width: constraints
                                          .constrainWidth(size.width * .25),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: .4),
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 5),
                                          child: IconButton(
                                              onPressed: () {},
                                              icon: GradientIcon(
                                                  Icons.add,
                                                  40,
                                                  LinearGradient(colors: [
                                                    Color(0xE0F169B6),
                                                    Color(0xDAF3B3D6),
                                                    Color(0xD37DCFFB),
                                                  ]))))),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: AutoSizeText("New"))
                                ],
                              );
                            },
                          ),
                        ])),
                // TODO: user recently visited, guess we'll pull this from matches? maybe. or maybe gps info... we'll see
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(children: [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText("Recently Visited",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)))),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
                            height: 1,
                            width: size.width / 1.1,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              Color(0xE0F169B6),
                              Color(0xDAF3B3D6),
                              Color(0xD37DCFFB),
                            ]))),
                      ),
                      ScrollableChips(widget.favorites)
                    ])),

                // TODO: user favorites, can be updated via edit profile. will need a scroll view most likely
                // will pull from the db. need to talk about if we're going to allow userse to favorite a restaurant from swipe
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(children: [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText("Favorites",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)))),
                      Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 1,
                              width: size.width / 1.1,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                Color(0xE0F169B6),
                                Color(0xDAF3B3D6),
                                Color(0xD37DCFFB),
                              ])))),
                      _userData.containsKey("favorites") ||
                              widget.favorites.length > 0
                          ? ScrollableChips(widget.favorites)
                          : Container(width: 70),
                    ])),
              ],
            ))));
  }
}
