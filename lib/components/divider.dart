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
        SizedBox(
            width: 40,
            child: Divider(
              color: notifire!.getMainText,
              height: 20,
              thickness: 1,
            )),
      ],
    ),
  );
}