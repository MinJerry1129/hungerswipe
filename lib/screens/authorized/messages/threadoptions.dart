import 'package:flutter/material.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';

class ThreadOptions extends StatefulWidget {
  const ThreadOptions({Key? key}) : super(key: key);

  @override
  _ThreadOptionsState createState() => _ThreadOptionsState();
}

class _ThreadOptionsState extends State<ThreadOptions> {
  late Map? _groupInfo;
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
          child: Text("Leave ${_groupInfo!['groupName']}'s Options Page"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
