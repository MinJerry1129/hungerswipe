import 'package:flutter/material.dart';

Widget linearGradientLine(BuildContext context, double height,
    {double width = 0}) {
  var size = MediaQuery.of(context).size;
  return Container(
      height: height,
      width: width != 0 ? width : size.width,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(0xE0F169B6),
        Color(0xDAF3B3D6),
        Color(0xD37DCFFB),
      ])));
}
