// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';

class LoadingDialog extends StatefulWidget {
  final String message;
  const LoadingDialog(this.message);
  @override
  LoadingDialogState createState() => new LoadingDialogState();
}

class LoadingDialogState extends State<LoadingDialog> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: LightModeColors["primary"],
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
                image: AssetImage("images/Icons/hungerswipe_logowhite.png"),
                width: width / 1.5),
            CircularProgressIndicator(color: Color(0xFF7DCEFB)),
            Padding(
                padding: EdgeInsets.only(top: 10),
                child: Container(
                  child: Text(widget.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  alignment: Alignment.center,
                ))
          ],
        ));
  }
}
