import 'package:flutter/material.dart';

class ColorConstant {

  static const Color primaryColor = Color(0xFF5B84D0);
  static const Color bgWhite = Color(0xFFF2F3F7);
  static const Color bgBlue = Color(0xFF191B2F);
  static const Color backgroundColor = Color(0xFFDEE6F6);
  static Color red = Colors.red.shade700;
  static const Color primaryTextColor = Color(0xFF323643);
  static const Color grayTextColor = Color(0xFF7E8392);
  static const Color verdigris = Color(0xff40b8b2);


  static LinearGradient loginBgLinearGradient = const LinearGradient(
    colors: [Colors.transparent, bgBlue],
    stops: [0.0, 1.0],
    begin: FractionalOffset.topCenter,
    end: FractionalOffset.bottomCenter,
  );
}
