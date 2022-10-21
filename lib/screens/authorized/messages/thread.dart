import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/widgets/getDate.dart';
import 'package:hungerswipe/helpers/widgets/group_swipe_button.dart';
import 'package:hungerswipe/helpers/widgets/user_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hungerswipe/screens/authorized/messages/threadoptions.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'dart:ui' as ui;

class Thread extends StatefulWidget {
  final int count;
  final Map? element;
  final args;
  Thread({Key? key, this.count = 0, this.args, this.element}) : super(key: key);

  @override
  _ThreadState createState() => _ThreadState();
}

class _ThreadState extends State<Thread> {
  late FirebaseFirestore _firestore;
  int messageCount = 0;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    setState(() {
      messageCount = widget.count;
    });

    // _grabDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Future<List> _membersPhotos() async {
  //   List _photoList = [];
  //   await _firestore.collection(_groupData['groupId']).snapshots();
  //   for snapshots.lengeth
  //   return _photoList;
  // }

  @override
  Widget build(BuildContext context) {
    Map _userData = AppStateScope.of(context).userData;
    final size = MediaQuery.of(context).size;
    Map _groupData = widget.element ?? widget.args['element'];
    List groupMembers = _groupData['members']
        .where((e) => e['username'] != _userData['username'])
        .toList();
    // List members = _groupData['members'];
    // members.removeWhere((i) => i['username'] == _userData['username']);
    // IconData _groupIcon = _groupData[''];
    print('${_groupData['members']} length');
    bool hasPhoto = data?['photoURL'] != null;
    String _groupName = _groupData['members'].length == 2
        ? groupMembers[0]['firstName'] + ' ' + groupMembers[0]['lastName']
        : _groupData['groupName'];
    Size _textSize(String text, TextStyle style) {
      final TextPainter textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 4,
          textDirection: ui.TextDirection.ltr)
        ..layout(minWidth: 0, maxWidth: double.infinity);
      return textPainter.size;
    }

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // here the desired height
          child: AppBar(
            // actions: <Widget>[
            //   Row(
            //     children: [
            //       Text(
            //         _groupData['groupName'],
            //       ),
            //       IconButton(
            //         onPressed: () {
            //           print('Info Icon presssed you dumbies');
            //         },
            //         icon: Icon(Icons.info_outline_rounded),
            //       ),
            //     ],
            //   ),
            //   IconButton(
            //     iconSize: 16,
            //     onPressed: () {},
            //     icon: Icon(Icons.info_outline_rounded),
            //   ),
            // ],
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 24,
                color: Color(
                  0xFFFA89A7,
                ),
              ),
              onPressed: () {
                AppStateWidget.of(context).updateAllMessageInfo(newMessageInfo);
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            title: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Container(
                        child: CircleAvatar(
                      backgroundImage: hasPhoto
                          ? NetworkImage(_groupData['photoURL'])
                          : AssetImage('images/Icons/no-user.jpg')
                              as ImageProvider,
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_groupName,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ThreadOptions()));
                          },
                          icon: Icon(
                            Icons.info_outlined,
                            color: Colors.grey,
                            size: size.height * 0.025,
                          ),
                        )
                      ],
                    )
                  ],
                )),

            // title: ListTile(
            //   subtitle: IconButton(
            //     onPressed: () {
            //       print('info icon pressed you dumbies');
            //     },
            //     icon: Icon(
            //       Icons.info_outline_rounded,
            //       size: 18,
            //     ),
            //     color: Colors.black,
            //   ),
            //   title: Text(
            //     widget.element['groupName'],
            //     style: TextStyle(
            //       color: Colors.black,
            //       fontWeight: FontWeight.w800,
            //       fontSize: 18,
            //     ),
            //   ),
            // ),
          )),
      body: Container(
        color: Colors.white,
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GroupSwipeButton(),
            StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('groups')
                    .doc(_groupData['groupId'])
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Text("loading");
                  // var data = document.data() as Map<String, dynamic>;
                  // bool fromSelf =
                  // return Column(
                  //   children: [
                  //     Row(
                  //       mainAxisAlignment: MainAxisAlignment.end,
                  //       children: [
                  //         Text(
                  //           "sad",
                  //           textAlign: TextAlign.end,
                  //         )
                  //       ],
                  //     )
                  //   ],
                  // );
                  return Flexible(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          // boxShadow: [
                          //   BoxShadow(
                          //     blurRadius: .07,
                          //     color: Colors.black12,
                          //     offset: Offset(-3.5, -3.5),
                          //   ),
                          // ],
                          ),
                      child: ListView(
                          reverse: true,
                          padding: EdgeInsets.all(10),
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            data = document.data() as Map<String, dynamic>;
                            Map message = data!;
                            int id = message['id'] == 0
                                ? message['id']
                                : message['id'] - 1;
                            DateTime _date = message['timestamp'].toDate();

                            DateTime _lastMsgDate = snapshot.data!.docs.reversed
                                .toList()[id]['timestamp']
                                .toDate();

                            DateTime _twoMsgsAgo = snapshot.data!.docs.reversed
                                .toList()[id == 0 ? id : id - 1]['timestamp']
                                .toDate();
                            var formattedDate = getDate(_date);

                            var currentDate = DateTime.now();

                            bool isToday = _date.day == currentDate.day;
                            bool isSameYear =
                                (_lastMsgDate.month == currentDate.month &&
                                    _lastMsgDate.year == currentDate.year);

                            bool lastFromYesterday =
                                currentDate.day - _date.day == 1 &&
                                    isSameYear &&
                                    (currentDate.day - _lastMsgDate.day != 1 ||
                                        message['id'] == 0);

                            bool lastFromToday =
                                (_lastMsgDate.day - currentDate.day < 0 ||
                                        message['id'] == 0) &&
                                    currentDate.day - _date.day == 0;

                            var dateTimeBuilder = lastFromToday
                                ? 'Today at ${formattedDate["cleanedDate"]}'
                                : lastFromYesterday
                                    ? 'Yesterday at ${formattedDate["cleanedDate"]}'
                                    : '${formattedDate["fullDate"]}';
                            print(
                                'last from yesterday: ${currentDate.day - _date.day} ${message["message"]} ${message["id"]}');
                            // print(
                            //     'last msg from yesterday: ${_twoMsgsAgo.day - currentDate.day} $lastFromYesterday ${message["id"]}');

                            // above texts within the same day

                            bool fromSelf = message['senderId'].toString() ==
                                _userData['phoneNumber'].toString();

                            final textStyle = TextStyle(
                                color: fromSelf ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500);

                            Size textSize =
                                _textSize(message['message'], textStyle);

                            return Row(
                              mainAxisAlignment: fromSelf
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 250,
                                  child: fromSelf
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                              lastFromToday ||
                                                      (lastFromYesterday &&
                                                          !isToday) ||
                                                      (currentDate.day -
                                                                  _date.day !=
                                                              1 &&
                                                          !isToday)
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                          Container(width: 0),
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10),
                                                              child: Text(
                                                                  dateTimeBuilder,
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xFF999999),
                                                                      fontSize:
                                                                          12))),
                                                          Spacer()
                                                        ])
                                                  : SizedBox.shrink(),
                                              Container(
                                                  width: textSize.width < 120
                                                      ? 120
                                                      : textSize.width,
                                                  child: Card(
                                                    elevation: 0,
                                                    color: Color(0xFF7DCEFB),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                      bottomLeft:
                                                          Radius.circular(24),
                                                      topLeft:
                                                          Radius.circular(24),
                                                      topRight:
                                                          Radius.circular(24),
                                                      bottomRight:
                                                          Radius.circular(6),
                                                    )),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5),
                                                      child: ListTile(
                                                        title: Text(
                                                            message['message'],
                                                            style: TextStyle(
                                                                color: fromSelf
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                      ),
                                                    ),
                                                  )),
                                            ])
                                      : Card(
                                          elevation: 0,
                                          color: Color(0xFFDADADA),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(6),
                                            topLeft: Radius.circular(24),
                                            topRight: Radius.circular(24),
                                            bottomRight: Radius.circular(24),
                                          )),
                                          child: Padding(
                                            padding: EdgeInsets.all(1),
                                            child: ListTile(
                                              title: Text(message['message'],
                                                  style: TextStyle(
                                                      color: fromSelf
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          )),
                                ),
                              ],
                            );
                          }).toList()),
                    ),
                  );
                }),
            Container(
              alignment: Alignment.bottomCenter,
              child: UserInput(
                parent: 'thread',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
