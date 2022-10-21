import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';

class GroupSwipe extends StatefulWidget {
  const GroupSwipe({Key? key}) : super(key: key);

  @override
  _GroupSwipeState createState() => _GroupSwipeState();
}

class _GroupSwipeState extends State<GroupSwipe> {
  late Map? _groupInfo;
  late FirebaseFirestore _firestore;
  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getGroupInfo() {
    _groupInfo = AppStateScope.of(context).messageInfo['groupInfo'];
    print('this is the group info: $_groupInfo');
  }

  @override
  Widget build(BuildContext context) {
    _getGroupInfo();
    return Scaffold(
      body: Center(
        child: TextButton(
          child: Text("Back to ${_groupInfo!['groupName']}'s Thread page"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
