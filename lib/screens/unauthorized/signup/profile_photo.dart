import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hungerswipe/screens/unauthorized/signup/favorites.dart';
import 'package:path/path.dart' as path;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/customIndicator.dart';
import 'package:hungerswipe/helpers/widgets/gradientButton.dart';
import 'package:hungerswipe/helpers/widgets/gradientIcon.dart';
import 'package:hungerswipe/helpers/widgets/profile_photo_dialog.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhoto extends StatefulWidget {
  @override
  _ProfilePhotoState createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  // bool isActive = false;
  final ImagePicker _picker = ImagePicker();
  var _image;
  bool _loading = false;
  bool _selected = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map _userData = AppStateScope.of(context).userData;

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
      setState(() {
        _loading = false;
      });

      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => Favorites()));
    }

    var statusBarHeight = MediaQuery.of(context).padding.top;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
            padding: EdgeInsets.only(top: statusBarHeight + 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back_ios_new,
                              color: LightModeColors["primary"], size: 24.0)),
                      customIndicator(context, 30),
                      TextButton(
                          child: Text("Skip",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400)),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    Favorites()));
                          })
                    ]),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text('Profile Photo',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold))),
                Padding(
                    padding: EdgeInsets.only(top: 80, bottom: 5),
                    child:
                        //         child: Text(this.error != "" ? this.error : "",
                        //             style:
                        //                 TextStyle(color: Colors.red, fontSize: 14)))),
                        !this._selected
                            ? DottedBorder(
                                strokeWidth: 1,
                                borderType: BorderType.Circle,
                                color: Colors.grey,
                                dashPattern: [10, 4],
                                child: Container(
                                    width: width / 1.5,
                                    height: 250,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(colors: [
                                          Color(0x40E54AAF),
                                          Color(0x40F3B3D6),
                                          Color(0x407DCEFB),
                                          Color(0x40364680),
                                        ])),
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Container(
                                          child: IconButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    barrierColor:
                                                        Color(0x96808080),
                                                    builder:
                                                        (BuildContext context) {
                                                      return profilePhotoDialog(
                                                          context,
                                                          selectCameraImage,
                                                          selectGalleryImage);
                                                    });
                                              },
                                              icon: GradientIcon(
                                                  Icons.camera_alt,
                                                  128.0,
                                                  LinearGradient(
                                                      begin:
                                                          Alignment(-.5, -0.5),
                                                      end: Alignment(0.5, 1),
                                                      colors: [
                                                        Color(0xFFFA89A7),
                                                        Color(0xFFED5DBB)
                                                      ],
                                                      stops: [
                                                        .2765,
                                                        .9644
                                                      ]))),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                                begin: Alignment(-1, -1),
                                                colors: [
                                                  Color(0x73E54AAF),
                                                  Color(0x73F3B3D6),
                                                  Color(0x737DCEFB),
                                                ],
                                                stops: [
                                                  -.1127,
                                                  .2116,
                                                  .8881,
                                                ]),
                                          )),
                                    )))
                            : Container(
                                width: width / 1.5,
                                height: 250,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [
                                      Color(0xE7E54AAF),
                                      Color(0xE8F3B3D6),
                                      Color(0xE37DCFFB),
                                    ])),
                                child: Padding(
                                    padding: EdgeInsets.all(1.5),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: TextButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  barrierColor:
                                                      Color(0x96808080),
                                                  builder:
                                                      (BuildContext context) {
                                                    return profilePhotoDialog(
                                                        context,
                                                        selectCameraImage,
                                                        selectGalleryImage);
                                                  });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      fit: BoxFit.fitWidth,
                                                      image: FileImage(
                                                          this._image))),
                                            )))),
                              )),
                Container(
                    width: 300,
                    child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Your profile photo is public.",
                                style: TextStyle(
                                    color: LightModeColors["helperText"],
                                    fontSize: 12)),
                            this._loading
                                ? CircularProgressIndicator()
                                : SizedBox.shrink()
                          ],
                        ))),
                Spacer(),
                Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child:
                        gradientButton(context, _uploadSelectedImage, "Next"))
              ],
            )));
  }
}
