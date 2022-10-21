import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class UserInput extends StatefulWidget {
  final String parent;
  const UserInput({Key? key, required this.parent}) : super(key: key);

  @override
  _UserInputState createState() => _UserInputState();
}

class _UserInputState extends State<UserInput> {
  late FirebaseFirestore _firestore;
  bool hasText = false;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _controller.addListener(_checkIfEmpty);
  }

  void _checkIfEmpty() {
    if (_controller.text.length > 0) {
      setState(() {
        hasText = true;
      });
    } else
      setState(() {
        hasText = false;
      });
  }

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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final Map _userData = AppStateScope.of(context).userData;
    final newGroupInfo = AppStateScope.of(context).messageInfo['groupInfo'];

    Future<void> _initGroup() async {
      var groupName = newGroupInfo['members'].length > 2
          ? '${_userData["firstName"]} ${_userData["lastName"]}\'s group'
          : '${newGroupInfo['members'][0]['firstName']} ${newGroupInfo['members'][0]['lastName']}';

      var groupId = Uuid().v1().split('-')[0];
      // var groupList = _firestore.collection("groups").snapshots();
      final _messageInfo = AppStateScope.of(context).messageInfo['messageInfo'];
      final _groupInfo = {
        "groupAdmins": [_userData['username']],
        "groupId": groupId,
        "groupName": groupName,
        "lastActive": DateTime.now(),
        "location": _userData['location'],
        "members": newGroupInfo['members'],
        "lastMessage": _messageInfo['message']
      };

      try {
        print('group info2: ${_groupInfo["members"]}');
        print('this is the user data: $_userData');
        _groupInfo['members'].add(_userData);
        print('group info: ${_groupInfo["members"]}');
        var _group = _firestore.collection("groups").doc(_groupInfo['groupId']);
        var _messageId = Uuid().v1().split('-')[0];
        await _group.set(_groupInfo);
        await _group.collection("messages").doc(_messageId).set({
          "message": _messageInfo['message'],
          "timestamp": DateTime.now(),
          "senderId": _userData['phoneNumber'],
          "id": 0
        });
        setState(() {
          AppStateWidget.of(context).updateAllMessageInfo({
            'messageInfo': initMessageInfo['messageInfo'],
            'groupInfo': _groupInfo
          });
        });
        Navigator.of(context)
            .popAndPushNamed("/thread", arguments: {"element": _groupInfo});
      } catch (e) {
        print(e);
      }
    }

    Future<void> _sendMessage() async {
      final Map _groupInfo = AppStateScope.of(context).messageInfo['groupInfo'];

      final Map _messageInfo =
          AppStateScope.of(context).messageInfo['messageInfo'];

      var _messageCount = AppStateScope.of(context).messageCount['count'];

      var _group = _firestore.collection("groups").doc(_groupInfo['groupId']);
      print(_groupInfo);
      var _messageId = Uuid().v1().split('-')[0];
      try {
        if (_messageInfo != initMessageInfo['messageInfo'] &&
            _groupInfo != initMessageInfo['groupInfo']) {
          try {
            await _group.update({
              "lastMessage": _messageInfo['message'],
              "lastActive": DateTime.now()
            });
            await _group.collection("messages").doc(_messageId).set({
              "message": _messageInfo['message'],
              "timestamp": DateTime.now(),
              "senderId": _userData['phoneNumber'],
              "id": _messageCount
            });
            // await _firestore
            //     .collection('groups')
            //     .doc(_groupInfo['groupId'])
            //     .get()
            //     .then((snapshot) {
            //   print(snapshot.data().toString());
            //   setState(() {
            //     AppStateWidget.of(context).updateAllMessageInfo({
            //       'messageInfo': initMessageInfo['messageInfo'],
            //       'groupInfo': snapshot.data(),
            //     });
            //   });
            // });
          } catch (e) {
            print('Error on _messageSend/FirebasePropigation: $e');
          }
        }
      } catch (e) {
        print('Error on _messageSend: $e');
      }
    }

    void _handleUpdate(message) {
      try {
        AppStateWidget.of(context).updateAllMessageInfo({
          'messageInfo': {
            'senderId': _userData['phoneNumber'],
            'message': message,
            'timestamp': DateTime.now(),
          },
        });
      } catch (e) {
        print('Error: $e');
      }
    }

    return Container(
      width: size.width / 1.05,
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        color: Color(0xFFF1F2F3),
      ),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Container(
                    // replace this container w camera ops
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: Color(0xFF7DCEFB)),
                    child: IconButton(
                      onPressed: () {
                        print('camera icon pushed dumbie');
                      },
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Container(
                    width: size.width * .6,
                    constraints: BoxConstraints(maxHeight: 240),
                    child: Material(
                      color: Colors.transparent,
                      child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            focusedBorder:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Message...',
                            fillColor: Colors.transparent,
                            filled: true,
                          ),
                          maxLines: 6,
                          minLines: 1,
                          keyboardType: TextInputType.multiline),
                    )),
              ],
            ),
            _controller.text.length == 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          print('mic icon pushed dumbie');
                          print(_controller.text);
                        },
                        icon: Icon(
                          Icons.mic_none_outlined,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          print('gallery icon pushed dumbie');
                        },
                        icon: Icon(
                          Icons.photo_library_outlined,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Container(
                      // replace this container w camera ops
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: Color(0xFF7DCEFB)),
                      child: IconButton(
                        onPressed: () {
                          if (_controller.text != '') {
                            if (widget.parent == 'new_message') {
                              _handleUpdate(_controller.text);
                              _initGroup();
                              // navigate to thread of said new group
                            } else if (widget.parent == 'thread') {
                              _handleUpdate(_controller.text);
                              _sendMessage();
                            }
                            _controller.clear();
                          }
                          print('camera icon pushed dumbie');
                        },
                        icon: Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
