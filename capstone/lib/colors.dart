import 'package:flutter/material.dart';

Color getColor(context, colorID) {
  Map<String, List<Color>> colorDictionary = {
    "white": [Colors.white, Colors.black],
    "black": [Colors.black, Colors.white],
    "gray": [const Color(0xFF8F9192), const Color(0xFF707274)],
    "red": [Colors.red, const Color(0xFFBD382F)],
    "lightDark": [const Color(0xFFEEEEEE), const Color(0xFF161616)],
    "systemBlue": [
      const Color.fromARGB(255, 0, 122, 255),
      const Color.fromARGB(255, 0, 122, 255)
    ],
    "completeGreen": [
      const Color(0xFF54BC59),
      const Color(0xFF4FB654),
    ],
    "incompleteRed": [Colors.red, const Color(0xFFBD382F)],
  };
  return colorDictionary[colorID]![
      MediaQuery.of(context).platformBrightness == Brightness.light ? 0 : 1];
}
