import 'package:flutter/material.dart';

import '../appstaticdata/colorfile.dart';

class ColorNotifire with ChangeNotifier {


  bool _isDark = false;
  bool get isDark => _isDark;

  void isavalable(bool value) {
    _isDark = value;
    notifyListeners();
  }

  bool get getIsDark => isDark;
  Color get getMainColor => isDark ? darkmainColor : mainColor;
  Color get getprimerycolor => isDark ? darkPrimeryColor : primeryColor;
  Color get getbgcolor => isDark ? darkbgcolor : bgcolor;
  Color get getbordercolor => isDark ? darkbordercolor : bordercolor;
  Color get geticoncolor => isDark ? darkiconcolor : iconcolor;
  Color get getcontiner => isDark ? darkcontinercolor : continercolor;
  Color get getcontinershadow => isDark ? darkcontinercolo1r : continercolo1r;

  Color get getTextColor1 => isDark ? textwhite : textdark;
  Color get getMainText => isDark ? themgrey : themblack;
  Color get getMaingey => isDark ? themblackgrey : themlitegrey;

  Color get getbacknoticolor => isDark ? darkbackcolor : notibackcolor;
  Color get getsubcolors => isDark ? darksubcolor : notisubcolor;
  Color get getbacktextcolors => isDark ? darktextcolor : backtextcolor;
  Color get getfiltextcolors => isDark ? darkfilcolor : filtexcolor;
  Color get getdolorcolors => isDark ? darkdolorcolor : dolorcolor;
  Color get getmaintext => isDark ? themblack1 : themgrey1;

  Color get success => !isDark ? Colors.green : Colors.green.shade800;
  Color get danger => !isDark ? Colors.red : Colors.red.shade800;
  Color get warning => !isDark ? Colors.amber : Colors.amber.shade800;
  Color get info => !isDark ? Colors.teal : Colors.teal.shade800;
}