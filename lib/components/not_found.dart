import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'icon.dart';

Widget notFoundTile({
  required String text,
  IconData? icon,
}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        cusFaIcon(
          icon ?? FontAwesomeIcons.circleExclamation,
          size: 50,
          color: notifire.getMaingey,
        ),
        SizedBox(height: 10),
        Text(
          text,
          style: mediumGreyTextStyle,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}