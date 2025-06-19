import 'package:flutter/material.dart';

import 'constant/color_constants.dart';

class ThemeClass {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: ThemeData.light().scaffoldBackgroundColor,
    scaffoldBackgroundColor: ColorConstant.bgWhite,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: 'Sofia Pro', // Use your custom font here
        fontSize: 16.0, // Adjust the font size as needed
      ),
    ),
    colorScheme: const ColorScheme.light().copyWith(
        primary: ColorConstant.primaryColor,
        secondary: ColorConstant.primaryColor),
    unselectedWidgetColor:
        ColorConstant.grayTextColor, // Unselected radio button color
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return ColorConstant.primaryColor;
        }
        return null;
      }),
    ),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white, // Set the background color to white
      iconTheme: IconThemeData(
          color: Colors
              .black), // Set the icon color to black for better visibility
      titleTextStyle: TextStyle(
        color: Colors.black, // Set the title text color to black
        fontSize: 20, // Adjust the font size as needed
      ),
      actionsIconTheme: IconThemeData(
          color: Colors.black), // Set the action icons color to black
    ),
  );
}
