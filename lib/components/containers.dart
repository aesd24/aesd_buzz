import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:flutter/material.dart';

Widget authContainer({
  required String title,
  required String subtitle,
  required Widget child
}) {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
        color: notifire!.getprimerycolor,
        borderRadius: const BorderRadius.all(Radius.circular(37))
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: mainTextStyle,
          ),
          Text(
            subtitle,
            style: mediumGreyTextStyle.copyWith(
                color: Colors.black54
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          child
        ],
      ),
    ),
  );
}