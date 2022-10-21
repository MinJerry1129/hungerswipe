import 'package:flutter/material.dart';

Widget customIndicator(BuildContext context, double value) {
  var screenWidth = MediaQuery.of(context).size.width;
  return Container(
      constraints:
          BoxConstraints.tightFor(height: 10, width: screenWidth / 1.5),
      decoration: BoxDecoration(
          color: Color(0xFFE5E5E5), borderRadius: BorderRadius.circular(36.0)),
      child: Row(
        children: [
          Container(
            width: value * 5,
            constraints: BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36.0),
                gradient: LinearGradient(stops: [
                  .10,
                  .45,
                  1
                ], colors: [
                  Color(0xFFF169B6),
                  Color(0xFFF3B3D6),
                  Color(0xFF7DCEFB),
                ])),
          ),
        ],
      ));
}
