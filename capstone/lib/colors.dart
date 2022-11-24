import 'package:flutter/material.dart';

Color getColor(context, colorID) {
  Map<String, List<Color>> colorDictionary = {
    "white": [Colors.white, Colors.black],
    "black": [Colors.black, Colors.white],
    "gray": [Color(0xFF8F9192), Color(0xFF707274)],
    "red": [Colors.red, Color(0xFFBD382F)],
    "lightDark": [const Color(0xFFFAFAFA), Color(0xFF161616)],
    "systemBlue": [
      const Color.fromARGB(255, 0, 122, 255),
      const Color.fromARGB(255, 0, 122, 255)
    ],
  };
  return colorDictionary[colorID]![
      MediaQuery.of(context).platformBrightness == Brightness.light ? 0 : 1];
}
