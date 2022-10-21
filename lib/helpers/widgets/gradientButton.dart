import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';

Widget gradientButton(
    BuildContext context, _submitPressed, String? buttonText) {
  var screenWidth = MediaQuery.of(context).size.width;
  return Container(
      width: screenWidth / 1.2,
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          // when active
          gradient: LinearGradient(colors: [
            LightModeColors["gradientLong"]["gradient1"],
            LightModeColors["gradientLong"]["gradient2"],
            LightModeColors["gradientLong"]["gradient3"],
          ], stops: [
            .10,
            .45,
            1
          ]),
          borderRadius: BorderRadius.circular(36.0),
          border: Border.all(width: 0, color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 0),
            )
          ]),
      child: SizedBox(
          width: screenWidth / 1.2,
          child: TextButton(
            onPressed: _submitPressed,
            child: Text(buttonText ?? "Next",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          )));
}
