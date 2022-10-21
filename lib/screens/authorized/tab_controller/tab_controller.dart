import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/hunger_swipe_icons_icons.dart';
import 'package:hungerswipe/helpers/widgets/gradientIcon.dart';

import 'package:hungerswipe/screens/authorized/home/home.dart';
import 'package:hungerswipe/screens/authorized/messages/messages.dart';
import 'package:hungerswipe/screens/authorized/profile/profile.dart';
import 'package:hungerswipe/screens/authorized/search/search.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';

class Tabs extends StatefulWidget {
  const Tabs({Key? key}) : super(key: key);
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var _index = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _userData = AppStateScope.of(context).userData;
    var statusBar = MediaQuery.of(context).padding.top;
    var modePreference = _userData['modePreference'];
    print('dark status pref: $modePreference');
    return Scaffold(
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        appBar: TabBar(
            physics: NeverScrollableScrollPhysics(),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.white,
            labelPadding: EdgeInsets.only(top: statusBar),
            controller: _tabController,
            onTap: (ind) {
              setState(() {
                _index = ind;
              });
            },
            tabs: [
              Tab(
                  icon: _index == 0
                      ? Material(
                          color: Colors.transparent,
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      spreadRadius: .75,
                                      blurRadius: 5,
                                      offset: Offset(3.5, 3.5),
                                    )
                                  ],
                                  gradient: LinearGradient(colors: [
                                    Color(0xFFFA89A7),
                                    Color(0xFFED5DBB)
                                  ])),
                              child: Icon(HungerSwipeIcons.home_outlined,
                                  color: Color(0xFFFFFFFF), size: 36)))
                      : Material(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Color(0xFFFA89A7), width: 2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(9))),
                          child: Icon(HungerSwipeIcons.home_outlined,
                              color: Color(0xC7ED5DBA), size: 36))),
              Tab(
                  icon: Container(
                child: GradientIcon(
                    Icons.search_outlined,
                    36,
                    LinearGradient(colors: [
                      Color(0xFFFA89A7),
                      Color(0xFFED5DBB),
                    ])),
              )),
              Tab(
                icon: _index == 2
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: -5,
                                blurRadius: 10,
                                offset: Offset(2, 1),
                              )
                            ]),
                        child: Image.asset(
                          'images/Icons/messages_filled.png',
                        ))
                    : Image.asset(
                        'images/Icons/MessagesOutlined.png',
                      ),
              ),
              Tab(
                icon: _index == 3
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                spreadRadius: -5,
                                blurRadius: 15,
                                offset: Offset(2, 1),
                              )
                            ]),
                        child: Image.asset(
                          'images/Icons/person_filled.png',
                        ))
                    : Image.asset(
                        'images/Icons/AccountIcon.png',
                      ),
              ),
            ]),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            Center(child: new Home()),
            Center(child: new Search()),
            Center(child: new Messages()),
            Center(child: new Profile(type: "self")),
          ],
        ));
  }
}
