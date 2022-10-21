import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/gradientIcon.dart';
import 'package:hungerswipe/helpers/widgets/profile_photo_dialog.dart';
import 'package:hungerswipe/helpers/widgets/scrollableChips.dart';
import 'package:hungerswipe/screens/unauthorized/signup/favorites.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class EditProfile extends StatefulWidget {
  final String name;
  final String username;
  final String bio;
  const EditProfile(
      {Key? key, required this.name, required this.username, required this.bio})
      : super(key: key);
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final List restaurants = [
    {
      "name": "McDonald's",
      "img": "images/Icons/mcdonalds.png",
      "selected": false,
    },
    {
      "name": "Chipotle",
      "img": "images/Icons/chipotle.png",
      "selected": false,
    },
    {
      "name": "Applebee's",
      "img": "images/Icons/applebees.png",
      "selected": false,
    },
    {
      "name": "Chick-fil-A",
      "img": "images/Icons/chickfila.png",
      "selected": false,
    },
    {
      "name": "Cheesecake Factory",
      "img": "images/Icons/cheesecakefactory.png",
      "selected": false,
    },
    {
      "name": "Panera",
      "img": "images/Icons/panerabread.png",
      "selected": false,
    },
  ];

  final ImagePicker _picker = ImagePicker();
  var _image;

  bool _loading = false;
  bool _selected = false;
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _firebaseStorage;
  String name = "";
  String username = "";
  String bio = "";

  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();

    _firestore = FirebaseFirestore.instance;
    _firebaseStorage = FirebaseStorage.instance;
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  @override
  Widget build(BuildContext build) {
    var statusBarHeight = MediaQuery.of(context).padding.top;
    var size = MediaQuery.of(context).size;
    var _userData = AppStateScope.of(context).userData;
    var favorites = _userData['favorites'];

    void handleFavoritesUpdate(newFavs) {
      setState(() {
        favorites = newFavs;
      });

      print('hardcore apple sauce $newFavs');
    }

    Future<void> _uploadSelectedImage() async {
      setState(() {
        _loading = true;
      });
      String _basename = path.basename(_image.toString().replaceAll("'", ''));
      Reference _storageRef = _firebaseStorage
          .ref()
          .child('profile_photos/${_userData["username"]}/$_basename');
      UploadTask _uploadTask = _storageRef.putFile(_image);
      var _downloadUrl = await (await _uploadTask).ref.getDownloadURL();
      AppStateWidget.of(context)
          .updateUserData("profilePhoto", _downloadUrl.toString());
      await _firestore
          .collection('users')
          .doc(_userData['phoneNumber'])
          .update({"profilePhoto": _downloadUrl.toString()});
      setState(() {
        _loading = false;
      });
    }

    Future<void> _submitChanges() async {
      var name =
          _nameController.text.length > 0 ? _nameController.text : widget.name;
      Map<String, Object?> data = {
        "firstName": name.split(' ')[0],
        "lastName": name.split(' ')[1],
        "username": _usernameController.text.length > 0
            ? _usernameController.text
            : widget.username,
        "bio":
            _bioController.text.length > 0 ? _bioController.text : widget.bio,
        "favorites": favorites
      };

      await _firestore
          .collection("users")
          .doc(_userData['phoneNumber'])
          .update(data);
      AppStateWidget.of(context).updateAllUserData(data);

      if (_selected) {
        await _uploadSelectedImage();
      }
      return Navigator.of(context).pop();
    }

    void handleRemoveItem() {
      return;
    }

    Future<void> selectCameraImage() async {
      final XFile? selectedImage =
          await _picker.pickImage(source: ImageSource.camera);
      if (selectedImage != null) {
        this._image = File(selectedImage.path);
        this._selected = true;
      }
    }

    Future<void> selectGalleryImage() async {
      final XFile? selectedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (selectedImage != null) {
          this._image = File(selectedImage.path);
          this._selected = true;
        }
      });
    }

    return MaterialApp(
        home: Scaffold(
            body: Container(
                color: Colors.white,
                child: Padding(
                    padding: EdgeInsets.only(top: statusBarHeight),
                    child: Container(
                        child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                child: Text("Cancel",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400)),
                                onPressed: () => Navigator.of(context).pop()),
                            TextButton(
                                child: Text("Edit Profile",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18)),
                                onPressed: () {}),
                            TextButton(
                                child: Text("Done",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                onPressed: _submitChanges)
                          ],
                        ),
                        Container(
                            height: 1.5,
                            width: size.width,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              Color(0xE0F169B6),
                              Color(0xDAF3B3D6),
                              Color(0xD37DCFFB),
                            ]))),
                        // profile photo container
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  image: !_selected
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              _userData['profilePhoto']),
                                          fit: BoxFit.cover)
                                      : DecorationImage(
                                          image: FileImage(this._image),
                                          fit: BoxFit.cover),
                                  shape: BoxShape.circle,
                                ))),
                        // 'change profile photo' text
                        TextButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  barrierColor: Color(0x96808080),
                                  builder: (BuildContext context) {
                                    return profilePhotoDialog(context,
                                        selectCameraImage, selectGalleryImage);
                                  });
                            },
                            child: Text("Change Profile Photo",
                                style: TextStyle(
                                    color: Color(0xFF7DCEFB), fontSize: 16))),
                        // 1.5px tall linear gradient line
                        Container(
                            height: 1.5,
                            width: size.width,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              Color(0xE0F169B6),
                              Color(0xDAF3B3D6),
                              Color(0xD37DCFFB),
                            ]))),
                        // edit profile inputs -- name, username, bio
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text("Name",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18))),
                                Container(
                                    width: size.width / 1.5,
                                    child: TextField(
                                        controller: _nameController,
                                        cursorColor: Colors.black,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: widget.name,
                                            hintStyle: TextStyle(
                                                color: Colors.black))))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text("Username",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18))),
                                Container(
                                    width: size.width / 1.5,
                                    child: TextField(
                                        controller: _usernameController,
                                        cursorColor: Colors.black,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: widget.username,
                                            hintStyle: TextStyle(
                                                color: Colors.black))))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 15, top: 10),
                                    child: Text("Bio",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18))),
                                Container(
                                    width: size.width / 1.5,
                                    child: TextField(
                                        controller: _bioController,
                                        maxLines: 3,
                                        minLines: 3,
                                        cursorColor: Colors.black,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: widget.bio,
                                            hintStyle: TextStyle(
                                                color: Colors.black)))),
                              ],
                            ),
                          ],
                        ),
                        // 1.5px tall linear gradient line
                        Container(
                            height: 1.5,
                            width: size.width,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              Color(0xE0F169B6),
                              Color(0xDAF3B3D6),
                              Color(0xD37DCFFB),
                            ]))),
                        // favorites list, first: heading, second: favorites list, third: add new favorite button
                        Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(top: 10, left: 15),
                                child: Container(
                                    child: Text("Favorites",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400)),
                                    alignment: Alignment.centerLeft)),
                            favorites.length > 0
                                // ? Container(width: 70)
                                ? Container(
                                    height: 100,
                                    child: ScrollableChips(favorites))
                                : Container(width: 70),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Container(
                                        alignment: favorites.length > 0
                                            ? null
                                            : Alignment.centerLeft,
                                        child: Container(
                                            height: 70,
                                            width: 70,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFFE8E6E6)),
                                            child: IconButton(
                                                onPressed: () => Navigator.of(
                                                        context)
                                                    .push(MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            Favorites(
                                                              type: 'from-edit',
                                                              handleFavoritesUpdate:
                                                                  handleFavoritesUpdate,
                                                            ))),
                                                icon: GradientIcon(
                                                    Icons.add,
                                                    50,
                                                    LinearGradient(colors: [
                                                      Color(0xE0F169B6),
                                                      Color(0xDAF3B3D6),
                                                      Color(0xD37DCFFB),
                                                    ])))))),
                                Container(width: 70),
                                Container(width: 70)
                              ],
                            )
                          ],
                        )
                      ],
                    ))))));
  }
}
