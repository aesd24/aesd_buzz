import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:flutter/material.dart';

Widget textDivider(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 15),
    child: Column(
      children: [
        Text(
          text,
          style: mediumBlackTextStyle.copyWith(color: notifire!.getMainText),
        ),
        const SizedBox(
          width: 5,
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          width: 40,
          height: 3,
          decoration: BoxDecoration(
              color: notifire!.getTextColor1,
              borderRadius: BorderRadius.circular(10)
          ),
        )
      ],
    ),
  );
}