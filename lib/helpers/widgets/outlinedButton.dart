import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';

Widget outlinedButton(BuildContext context, double? radius) {
  var screenWidth = MediaQuery.of(context).size.width;
  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 0),
          )
        ]),
    child: OutlineGradientButton(
      onTap: () {},
      child: Container(
          width: screenWidth / 1.5,
          child: Text('Next',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: LightModeColors["buttonText"],
                  fontWeight: FontWeight.w500,
                  fontSize: 18))),
      gradient: LinearGradient(
        colors: [
          LightModeColors["gradientLong"]["gradient1"],
          LightModeColors["gradientLong"]["gradient2"],
          LightModeColors["gradientLong"]["gradient3"],
        ],
      ),
      strokeWidth: .5,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      radius: Radius.circular(radius ?? 36),
    ),
  );
}
