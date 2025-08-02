import 'package:flutter/material.dart';

import '../appstaticdata/colorfile.dart';

class ColorNotifire with ChangeNotifier {


  bool _isDark = false;
  bool get isDark => _isDark;

  void isavalable(bool value) {
    _isDark = value;
    notifyListeners();
  }

  get getIsDark => isDark;
  get getprimerycolor => isDark ? darkPrimeryColor : primeryColor;
  get getbgcolor => isDark ? darkbgcolor : bgcolor;
  get getbordercolor => isDark ? darkbordercolor : bordercolor;
  get geticoncolor => isDark ? darkiconcolor : iconcolor;
  get getcontiner => isDark ? darkcontinercolor : continercolor;
  get getcontinershadow => isDark ? darkcontinercolo1r : continercolo1r;

  get getTextColor1 => isDark ? textwhite : textdark;
  get getMainText => isDark ? themgrey : themblack;
  get getMaingey => isDark ? themblackgrey : themlitegrey;

  get getbacknoticolor => isDark ? darkbackcolor : notibackcolor;
  get getsubcolors => isDark ? darksubcolor : notisubcolor;
  get getbacktextcolors => isDark ? darktextcolor : backtextcolor;
  get getfiltextcolors => isDark ? darkfilcolor : filtexcolor;
  get getdolorcolors => isDark ? darkdolorcolor : dolorcolor;
  get getmaintext => isDark ? themblack1 : themgrey1;
}