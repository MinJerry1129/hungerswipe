import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/linearGradientLine.dart';
import 'package:hungerswipe/helpers/widgets/smallerTypeaheadField.dart';
import 'package:hungerswipe/screens/authorized/messages/thread.dart';
// import 'package:hungerswipe/screens/authorized/profile/profile.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:hungerswipe/screens/authorized/messages/newmessage.dart';
import 'package:intl/intl.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List<Map<dynamic, dynamic>> _users = <Map<dynamic, dynamic>>[];
  // List<Map<dynamic, dynamic>> _groups = <Map<dynamic, dynamic>>[];
  late TextEditingController _searchController;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? data;
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _grabUsers();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  List<Map?> _getSuggestions(String query) {
    String countryCode = AppStateScope.of(context)
        .userData['phoneNumber']
        .toString()
        .substring(0, 2);
    List<Map> matches = [];
    if (query != '') {
      matches.addAll(_users);

      matches.retainWhere((u) =>
          u['phoneNumber']
              .toString()
              .toLowerCase()
              .contains("$countryCode${query.toLowerCase()}") ||
          u['username']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          u['firstName']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          u['lastName']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          '${u["firstName"]} ${u["lastName"]}'
              .toLowerCase()
              .contains(query.toLowerCase()));
      // return matches;
    }
    return matches;
  }

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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var _userData = AppStateScope.of(context).userData;

    void _newMessage() {
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
      setState(() {
        AppStateWidget.of(context).updateAllMessageInfo(initMessageInfo);
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          // route to newMessage w searchedUserParams
          builder: (BuildContext context) => NewMessage(),
        ),
      );
    }

    Future<void> getMessageCount(groupId) async {
      var _group = FirebaseFirestore.instance.collection("groups").doc(groupId);
      await _group
          .collection("messages")
          .snapshots()
          .forEach((QuerySnapshot snapshot) {
        print('bougie bitch ${snapshot.docs.length}');
        AppStateWidget.of(context).updateMessageCount(snapshot.docs.length);
      });
    }

    return Scaffold(
        body: Column(children: [
      Container(height: 1, color: Color(0xFFE8E6E6), width: size.width),
      SmallerTypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _searchController,
          autofocus: false,
          cursorWidth: 1,
          cursorColor: Colors.black,
          cursorRadius: Radius.circular(12),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(5),
            fillColor: Color(0xFFE5E5E5),
            filled: true,
            hintText: "Search",
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(8)),
            prefixIcon: Icon(
              Icons.search_outlined,
              color: Color(0xFF999999),
            ),
            hintStyle: TextStyle(
              color: Color(0xFF999999),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        suggestionsCallback: (pattern) {
          return _getSuggestions(pattern);
        },
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          shadowColor: Colors.transparent,
          color: Colors.transparent,
        ),
        noItemsFoundBuilder: (BuildContext context) => Text(
          '',
          style: TextStyle(
            color: Theme.of(context).errorColor,
          ),
        ),
        itemBuilder: (context, suggestion) {
          Map user = suggestion as Map;
          return Card(
            elevation: 50.0,
            color: Colors.white,
            child: Container(
              width: size.width / 1.2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    user['profilePhoto'],
                  ),
                ),
                title: Text(
                  '${user["firstName"]} ${user["lastName"]}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  user['username'],
                ),
              ),
            ),
          );
        },
        onSuggestionSelected: (suggestion) {
          Navigator.of(context, rootNavigator: true).pushNamed("/newMessage");
          _searchController.clear();
          // _searchController.dispose();
        },
      ),
      Container(
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AutoSizeText(
              'MESSAGES',
              style: TextStyle(
                fontSize: 18,
                color: LightModeColors['primary'],
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: _newMessage,
              child: Image.asset(
                'images/Icons/new_message.png',
                scale: 1.03,
              ),
            ),
          ],
        ),
      ),
      StreamBuilder<QuerySnapshot>(
          stream:
              _firestore.collection("groups").orderBy("lastActive").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState == ConnectionState.waiting)
              return Text("loading");
            if (snapshot.data!.docs.length == 0) return Container();
            return Flexible(
              child: ListView(
                padding: EdgeInsets.all(10),
                scrollDirection: Axis.vertical,
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      data = document.data() as Map<String, dynamic>;
                      Map group = data!;
                      bool userInGroup = group['members']
                          .map((item) => item['username'])
                          .toList()
                          .contains(_userData['username']);
                      String lastMessage = group['lastMessage'] ?? '';
                      bool splitMessage = lastMessage.length > 30;
                      bool hasPhoto = data?['photoURL'] != null;
                      DateTime lastActive = group['lastActive'].toDate();
                      var amPm = lastActive.hour >= 12 ? "P.M." : "A.M.";
                      List groupMembers = group['members']
                          .where((e) => e['username'] != _userData['username'])
                          .toList();
                      String _groupName = group['members'].length == 2
                          ? groupMembers[0]['firstName'] +
                              ' ' +
                              groupMembers[0]['lastName']
                          : group['groupName'];
                      String _dateFormat =
                          DateFormat('kk:mm:ss').format(lastActive);
                      String _cleanDate = int.parse(_dateFormat.split(':')[0]) >
                              12
                          ? "${int.parse(_dateFormat.split(':')[0]) - 12}:${_dateFormat.split(':')[1]} $amPm"
                          : "$_dateFormat $amPm";
                      print('$_dateFormat $amPm');
                      return userInGroup
                          ? Column(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    print(group.toString());
                                    getMessageCount(group['groupId']);
                                    AppStateWidget.of(context)
                                        .updateAllMessageInfo(
                                            {'groupInfo': group});
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            Thread(
                                          element: group,
                                        ),
                                        // fullscreenDialog: true,
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      linearGradientLine(context, 1,
                                          width: size.width / 1.3),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 12, left: 15),
                                            child: Container(
                                              height: 46,
                                              width: 46,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(36),
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                backgroundImage: hasPhoto
                                                    ? NetworkImage(
                                                        group['photoURL'])
                                                    : AssetImage(
                                                            'images/Icons/no-user.jpg')
                                                        as ImageProvider,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AutoSizeText(
                                                  _groupName,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                AutoSizeText(
                                                    splitMessage
                                                        ? "${lastMessage.toString().substring(0, 30)}..."
                                                        : lastMessage,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF999999),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400))
                                              ],
                                            ),
                                          ),
                                          Spacer(),
                                          Text(_cleanDate,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF999999)))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column();
                    })
                    .toList()
                    .reversed
                    .toList(),
              ),
            );
          })
    ]));
  }
}
