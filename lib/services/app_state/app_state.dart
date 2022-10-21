import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/widgets/swipeCard.dart';
import 'package:hungerswipe/screens/authorized/home/home.dart';

class AppState {
  AppState({
    required this.userData,
    required this.restaurants,
    required this.messageInfo,
    required this.messageCount,
  });
  final Map messageInfo;
  final Map userData;
  final List<RestaurantItem> restaurants;
  final Map messageCount;
  // define what data structure components will be needed throughout multiple components,
  // i.e. overhaul of user's firebase doc ?? i think later in the file

  AppState copyWith({
    Map? userData,
    List<RestaurantItem>? restaurants,
    Map? messageInfo,
    Map? messageCount,
  }) {
    return AppState(
      messageInfo: messageInfo ?? this.messageInfo,
      restaurants: restaurants ?? this.restaurants,
      userData: userData ?? this.userData,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}

class AppStateScope extends InheritedWidget {
  AppStateScope(this.data, {Key? key, required Widget child})
      : super(key: key, child: child);

  final AppState data;

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.data;
  }

  @override
  bool updateShouldNotify(AppStateScope oldWidget) {
    return data != oldWidget.data;
  }
}

class AppStateWidget extends StatefulWidget {
  AppStateWidget({required this.child});

  final Widget child;

  static AppStateWidgetState of(BuildContext context) {
    return context.findAncestorStateOfType<AppStateWidgetState>()!;
  }

  @override
  AppStateWidgetState createState() => AppStateWidgetState();
}

final Map initialUserState = {
  "allergies": [],
  "cuisines": [],
  "dateJoined": DateTime,
  "deviceTokens": [],
  "email": '',
  "favorites": [],
  "firstName": '',
  "friends": {},
  "groupIds": [],
  "lastActive": DateTime,
  "lastName": '',
  "location": {},
  "modePreference": '',
  "notificationAccess": false,
  "phoneNumber": '',
  "profilePhoto": '',
  "username": '',
};

final Map newMessageInfo = {
  'messageInfo': {
    'senderId': '',
    'timestamp': DateTime,
    'message': '',
    'id': '',
  },
  'groupInfo': {
    "groupAdmins": [],
    "groupId": '',
    "groupName": '',
    "lastActive": DateTime,
    "location": {},
    "members": [],
    "messages": [],
  },
};

final Map messageCount = {"count": 0};

class AppStateWidgetState extends State<AppStateWidget> {
  // initial propigation from firestore, will hard code for now
  AppState _data = AppState(
    messageInfo: newMessageInfo,
    userData:
        initialUserState, // check auth, if firebase.firestore('users').doc(whatever_auth_shit).get()
    restaurants: [],
    messageCount: messageCount,
  );

  Future<bool> _checkMode() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseFirestore _store = FirebaseFirestore.instance;
    if (_auth.currentUser != null) {
      var darkModeStatus = await _store
          .collection("users")
          .doc(_auth.currentUser?.phoneNumber)
          .get()
          .then((DocumentSnapshot snapshot) {
        Map data = snapshot.data() as Map;
        if (data["modePreference"] == "dark-mode") {
          return true;
        } else
          return false;
      });
      if (darkModeStatus == true)
        return true;
      else
        return false;
    }
    return false;
  }

  void updateUserData(key, newVal) {
    setState(() {
      _data.userData.update(key, (val) => newVal);
    });
  }

  void updateMessageInfo(key, newVal) {
    setState(() {
      _data.messageInfo['messageInfo'].update(key, (value) => newVal);
    });
  }

  void updateMessageCount(count) {
    setState(() {
      _data.messageCount.update("count", (value) => value = count);
    });
  }

  /* void  */

  void addMember(member) {
    setState(() {
      _data.messageInfo['groupInfo']['members'].add(member);
    });
  }

  void removeLastMember() {
    setState(() {
      _data.messageInfo['groupInfo']['members'].removeLast();
    });
  }

  void removeAllMembers() {
    setState(() {
      _data.messageInfo['groupInfo']['members'].clear();
    });
  }

  void updateGroupInfo(key, newVal) {
    setState(() {
      _data.messageInfo['groupInfo'].update(key, (value) => newVal);
    });
  }

  void updateAllUserData(Map<String, dynamic> data) {
    print('updating user data -- $data');
    setState(() {
      data.forEach((key, value) {
        if (_data.userData.containsKey(key)) {
          _data.userData.update(key, (val) => value);
        } else
          _data.userData[key] = value;
      });
    });
  }

  void updateAllMessageInfo(Map<dynamic, dynamic> data) {
    // print(
    //     'Pre AppState updateAllMessageInfo  ==> ${_data.messageInfo.toString()}');
    if (mounted)
      setState(() {
        data.forEach((key, value) {
          if (_data.messageInfo.containsKey(key)) {
            _data.messageInfo.update(key, (val) => value);
          } else
            _data.messageInfo[key] = value;
        });
      });
    // print(
    //     'Post AppState updateAllMessageInfo  ==> ${_data.messageInfo.toString()}');
  }

  void propagateUserData(Map data) {
    // propagate from main, won't do it rn because i'm tired asf
  }

  void updateRestaurants(List _restaurantData) {
    _restaurantData.forEach((restaurant) {
      RestaurantItem _item = RestaurantItem(content: restaurant);
      _data.restaurants.add(_item);
    });
  }

  void addRestaurant(Map restaurant) {
    RestaurantItem _item = RestaurantItem(content: restaurant);
    _data.restaurants.add(_item);
  }

  // to change userData ------> AppStateWidget.of(context).updateUserData(key: key, newVal: update)

  Widget build(BuildContext context) {
    return AppStateScope(_data, child: widget.child);
  }
}
