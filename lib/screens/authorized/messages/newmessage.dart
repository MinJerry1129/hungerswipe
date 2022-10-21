import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:hungerswipe/helpers/widgets/autofill.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:hungerswipe/helpers/widgets/user_input.dart';

class NewMessage extends StatefulWidget {
  NewMessage({Key? key}) : super(key: key);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _searchController = TextEditingController();
  String? message;
  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _grabUsers();
    _grabGroups();
  }

  late FirebaseFirestore _firestore;
  List<Map<dynamic, dynamic>> _users = <Map<dynamic, dynamic>>[];
  List<Map<dynamic, dynamic>> _groups = <Map<dynamic, dynamic>>[];

  Map initMessageInfo = {
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
      "messages": [],
    },
  };

  Future<void> _grabUsers() async {
    await _firestore
        .collection("users")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<dynamic, dynamic> data = doc.data() as Map<dynamic, dynamic>;
        _users.add(data);
      });
    });
  }

  // keeping so we can filter out matching List<group['members']>

  Future<void> _grabGroups() async {
    await _firestore
        .collection("groups")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<dynamic, dynamic> data = doc.data() as Map<dynamic, dynamic>;
        _groups.add(data);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var statusBar = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(top: statusBar),
                        child: Container(
                          width: size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(width: 75),
                                AutoSizeText(
                                  'New Message',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    fontSize: 18,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      AppStateWidget.of(context)
                                          .updateAllMessageInfo(
                                              initMessageInfo);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: AutoSizeText(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.blue[400],
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
                AutoFill()
              ],
            ),
            UserInput(parent: 'new_message')
          ],
        ),
      ),
    );
  }
}
