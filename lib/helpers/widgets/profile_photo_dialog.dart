import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';

Widget profilePhotoDialog(
    BuildContext context, _cameraOnPress, _galleryOnPress) {
  var width = MediaQuery.of(context).size.width;
  return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      content: Column(mainAxisAlignment: MainAxisAlignment.end),
      actions: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              color: Colors.transparent,
              child: Column(children: [
                Container(
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.5),
                      gradient: LinearGradient(
                        colors: [
                          LightModeColors["gradientLong"]["gradient1"],
                          LightModeColors["gradientLong"]["gradient2"],
                          LightModeColors["gradientLong"]["gradient3"],
                        ],
                      ),
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.5),
                          ),
                          child: Column(
                            children: [
                              TextButton(
                                  child: Text('Take Photo',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  onPressed: () {
                                    _cameraOnPress();
                                    Navigator.of(context).pop();
                                  }),
                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      LightModeColors["gradientLong"]
                                          ["gradient1"],
                                      LightModeColors["gradientLong"]
                                          ["gradient2"],
                                      LightModeColors["gradientLong"]
                                          ["gradient3"],
                                    ],
                                  ),
                                ),
                              ),
                              TextButton(
                                  child: Text('Choose from Library',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  onPressed: () {
                                    _galleryOnPress();
                                    Navigator.of(context).pop();
                                  }),
                            ],
                          ),
                        ))),
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Container(
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.5),
                          gradient: LinearGradient(
                            colors: [
                              LightModeColors["gradientLong"]["gradient1"],
                              LightModeColors["gradientLong"]["gradient2"],
                              LightModeColors["gradientLong"]["gradient3"],
                            ],
                          ),
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.5),
                              ),
                              child: Column(
                                children: [
                                  TextButton(
                                      child: Text('Cancel',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }),
                                ],
                              ),
                            ))))
              ]),
            ),
          ],
        )
      ]);
}
