import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  GradientText(this.text,
      {required this.gradient, required this.fontSize, this.centerText});

  final String text;
  final double fontSize;
  final Gradient gradient;
  final bool? centerText;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: AutoSizeText(
        text,
        textAlign: centerText == true ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          // The color must be set to white for this to work
          color: Colors.white,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
