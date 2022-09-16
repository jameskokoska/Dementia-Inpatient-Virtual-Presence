import 'package:flutter/material.dart';

//import 'package:budget/colors.dart';
//Theme.of(context).colorScheme.lightDarkAccent

extension ColorsDefined on ColorScheme {
  Color get white =>
      brightness == Brightness.light ? Colors.white : Colors.black;
  Color get black =>
      brightness == Brightness.light ? Colors.black : Colors.white;
  Color get textLight =>
      brightness == Brightness.light ? Color(0xFF888888) : Color(0xFF494949);
  Color get textLightHeavy =>
      brightness == Brightness.light ? Color(0xFF888888) : Color(0xFF1D1D1D);
  Color get lightDarkAccent => brightness == Brightness.light
      ? const Color(0xFFFAFAFA)
      : Color(0xFF161616);
  Color get lightDarkAccentHeavyLight =>
      brightness == Brightness.light ? Color(0xFFFFFFFF) : Color(0xFF242424);
  Color get canvasContainer => brightness == Brightness.light
      ? const Color(0xFFEBEBEB)
      : const Color(0xFF242424);
  Color get lightDarkAccentHeavy => brightness == Brightness.light
      ? Color(0xFFEBEBEB)
      : const Color(0xFF444444);
  Color get shadowColor => brightness == Brightness.light
      ? const Color(0x655A5A5A)
      : const Color(0x69BDBDBD);
  Color get shadowColorLight => brightness == Brightness.light
      ? const Color(0x2D5A5A5A)
      : Color(0x28747474);
  Color get accentColor =>
      brightness == Brightness.light ? Colors.blue : Colors.blue;
  Color get accentColorHeavy =>
      brightness == Brightness.light ? Colors.blue : Colors.blue;
}
