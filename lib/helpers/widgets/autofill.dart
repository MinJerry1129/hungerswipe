import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hungerswipe/helpers/widgets/linearGradientLine.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';

class AutoFill extends StatefulWidget {
  const AutoFill({Key? key}) : super(key: key);

  @override
  _AutoFillState createState() => _AutoFillState();
}

class _AutoFillState extends State<AutoFill> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FocusNode _autofillNode = FocusNode();
  TextEditingController _autofillController = TextEditingController();
  List _users = [];
  List _matches = [];
  List _allUsers = [];
  Map<String, dynamic> initMessageInfo = {
    'messageInfo': {
      'senderId': '',
      'timestamp': DateTime,
      'message': '',
    },
    'groupInfo': {
      "groupAdmins": [],
      "groupId": '',
      "groupName": '',
      "lastActive": DateTime,
      "location": {},
      "members": [],
    },
  };

  @override
  void initState() {
    super.initState();
    _getAllUsers();
    _autofillController.addListener(_checkMatches);
  }

  @override
  void dispose() {
    super.dispose();
    _autofillController.dispose();
  }

  void _handleCheckKey(RawKeyEvent event) {
    var entry = _autofillController.text;
    if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
      if (entry == "") {
        if (_users.length > 0) {
          setState(() {
            _users.removeLast();

            AppStateWidget.of(context).removeLastMember();
            print('removed last: $_users');
          });
        }
      }
    }
  }

  Future<void> _getAllUsers() async {
    final QuerySnapshot users = await _firestore.collection("users").get();
    final List<DocumentSnapshot> documents = users.docs;
    documents.forEach((element) {
      _allUsers.add(element.data());
    });
  }

  void _checkMatches() {
    setState(() {
      _matches = [];
    });
    String entry = _autofillController.text;
    if (entry != "") {
      _allUsers.forEach((user) {
        print(user);
        String username = user['username'].toString().toLowerCase();
        String phoneNumber = user['phoneNumber'].toString().toLowerCase();
        String name = '${user["firstName"]} ${user["lastName"]}'.toLowerCase();
        if (username.contains(entry) ||
            phoneNumber.contains(entry) ||
            name.contains(entry)) {
          if (_users.length > 0) {
            _users.forEach((subUser) {
              if (username != subUser['username']) {
                setState(() {
                  _matches.add(user);
                });
              }
            });
          } else
            setState(() {
              _matches.add(user);
            });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // var groupInfo = AppStateScope.of(context).messageInfo;
    void _handleAddUserToList(Map user) {
      print('user $user');
      print('lisst $_users');
      setState(() {
        _users.add(user);
        AppStateWidget.of(context).addMember(user);
        print(AppStateScope.of(context).messageInfo);
        _matches = [];
        _autofillController.text = "";
      });
    }

    return Padding(
        padding: EdgeInsets.all(10),
        child: Container(
            child: Column(
          children: [
            linearGradientLine(context, 1),
            Row(children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    "To:",
                    style: TextStyle(color: Color(0xFF999999)),
                  )),
              _users.length > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // highly inefficient, a new method will need to be implemented before full launch
                        Row(
                            children: _users
                                .asMap()
                                .map((i, user) => MapEntry(
                                    i,
                                    Padding(
                                        padding: EdgeInsets.only(right: 3),
                                        child: Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                                color: i <= 1
                                                    ? Colors
                                                        .white // Color(0xFFDADADA)
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                            child: i <= 1
                                                ? Text(
                                                    "${'${user["firstName"]} ${user["lastName"]} '}",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF7DCEFB),
                                                        fontWeight:
                                                            FontWeight.w600))
                                                : SizedBox.shrink()))))
                                .values
                                .toList()),
                        _users.length > 2
                            ? Row(
                                children: _users
                                    .asMap()
                                    .map((i, user) => MapEntry(
                                        i,
                                        Padding(
                                            padding: EdgeInsets.only(top: 2),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: i >= 2 && i <= 3
                                                        ? Colors
                                                            .white // Color(0xFFDADADA)
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                                child: i >= 2 && i <= 3
                                                    ? Padding(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        child: Text(
                                                            "${'${user["firstName"]} ${user["lastName"]} '}",
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF7DCEFB))))
                                                    : SizedBox.shrink()))))
                                    .values
                                    .toList())
                            : SizedBox.shrink(),
                      ],
                    )
                  : SizedBox.shrink(),
              Expanded(
                  child: RawKeyboardListener(
                      onKey: (event) {
                        _handleCheckKey(event);
                      },
                      focusNode: _autofillNode,
                      child: TextField(
                        controller: _autofillController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      )))
            ]),
            linearGradientLine(context, 1),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _matches.map((user) {
                String name = user['firstName'] + ' ' + user['lastName'];
                bool hasPhoto = user['profilePhoto'] != '';
                String profilePhoto = user['profilePhoto'];
                return Column(children: [
                  TextButton(
                      onPressed: () {
                        _handleAddUserToList(user);
                      },
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                  backgroundImage: hasPhoto
                                      ? NetworkImage(profilePhoto)
                                      : AssetImage("images/Icons/no-user.jpg")
                                          as ImageProvider),
                              Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(name,
                                      style: TextStyle(color: Colors.black)))
                            ],
                          ))),
                  linearGradientLine(context, 1.5, width: size.width * .775)
                ]);
              }).toList(),
            )
          ],
        )));
  }
}

// ListView(
//             scrollDirection: Axis.horizontal,
//             children: _users.map((user) {
//               return Row(children: [Text(user)]);
//             }).toList(),
//           ),
