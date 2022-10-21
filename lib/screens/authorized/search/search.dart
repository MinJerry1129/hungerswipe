import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/widgets/smallerTypeaheadField.dart';
import 'package:hungerswipe/screens/authorized/profile/profile.dart';

class Search extends StatefulWidget {
  Search({Key? key}) : super(key: key);
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late TextEditingController _searchController;
  late FirebaseFirestore _firestore;
  List<Map<dynamic, dynamic>> _users = <Map<dynamic, dynamic>>[];
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _firestore = FirebaseFirestore.instance;
    _grabUsers();
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
    print('users: $_users');
  }

  List<Map?> _getSuggestions(String query) {
    List<Map> matches = [];
    if (query != '') {
      matches.addAll(_users);

      matches.retainWhere((u) =>
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
      return matches;
    }
    return matches;
  }

  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
        padding: EdgeInsets.only(top: 15),
        child: Container(
            alignment: Alignment.topCenter,
            width: size.width / 1.15,
            child: SmallerTypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchController,
                  autofocus: false,
                  cursorWidth: 1,
                  cursorColor: Colors.black,
                  cursorRadius: Radius.circular(12),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      fillColor: Color(0xFFE5E5E5),
                      filled: true,
                      hintText: "Search",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          Icon(Icons.search_outlined, color: Color(0xFF999999)),
                      hintStyle: TextStyle(
                          color: Color(0xFF999999),
                          fontWeight: FontWeight.w600))),
              suggestionsCallback: (pattern) {
                return _getSuggestions(pattern);
              },
              suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  shadowColor: Colors.transparent, color: Colors.transparent),
              noItemsFoundBuilder: (BuildContext context) => Text('',
                  style: TextStyle(color: Theme.of(context).errorColor)),
              itemBuilder: (context, suggestion) {
                Map user = suggestion as Map;
                return Container(
                    width: size.width / 1.2,
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundImage: NetworkImage(user['profilePhoto'])),
                      title: Text('${user["firstName"]} ${user["lastName"]}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(user['username']),
                    ));
              },
              onSuggestionSelected: (suggestion) {
                Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (BuildContext context) => Profile(
                            profileInfo: suggestion as Map, type: "user")));
              },
            )));
  }
}

//  Container(
//                 width: size.width / 1.15,
//                 height: 35,
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     color: Color(0xFFE5E5E5)),
//                 child: TextField(
//                   textAlignVertical: TextAlignVertical.center,
//                   cursorHeight: 20,
//                   controller: _searchController,
//                   cursorColor: Colors.black,
//                   decoration: InputDecoration(
//                       contentPadding: EdgeInsets.only(bottom: 15),
//                       hintText: "Search",
//                       border: InputBorder.none,
//                       prefixIcon:
//                           Icon(Icons.search_outlined, color: Color(0xFF999999)),
//                       hintStyle: TextStyle(
//                           color: Color(0xFF999999),
//                           fontWeight: FontWeight.w600)),
//                   style: TextStyle(
//                       color: Colors.black, fontWeight: FontWeight.w600),
//                 )),
