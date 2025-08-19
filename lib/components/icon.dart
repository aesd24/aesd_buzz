import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Color defaultColor = notifire.geticoncolor;

Widget cusFaIcon(IconData iconData, {
  Color? color, double size = 18
}) {
  return FaIcon(iconData, size: size, color: color ?? defaultColor);
}

Widget cusIcon(IconData iconData, {
  Color? color, double size = 18
}) {
  return Icon(iconData, size: size, color: color ?? defaultColor);
}