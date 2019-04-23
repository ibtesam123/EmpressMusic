import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeThemeLight {
  static Color appBarGradient1=Color.fromRGBO(255, 94, 98, 1);
  static Color appBarGradient2 = Color.fromRGBO(255, 153, 102, 1);
}

class _HomeThemeDark {
  static Color appBarGradient1 = Color.fromRGBO(255, 153, 102, 1);
  static Color appBarGradient2=Color.fromRGBO(255, 94, 98, 1);
}

// class HomeTheme with _HomeThemeDark,_HomeThemeLight{
//    static Color appBarGradient1=_HomeThemeDark.appBarGradient1;
//    static Color appBarGradient2=_HomeThemeDark.appBarGradient2;
// }