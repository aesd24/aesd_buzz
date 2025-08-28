import 'dart:io';

import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget idPictureContainer({
  IconData? icon,
  required void Function() onPressed,
  File? image
}) {
  return GestureDetector(
    onTap: () => onPressed(),
    child: CircleAvatar(
      radius: 60,
      backgroundColor: notifire!.getMaingey,
      backgroundImage: FileImage(image ?? File("")),
      child: image == null ? FaIcon(
        icon ?? FontAwesomeIcons.idBadge,
        size: 35,
        color: notifire!.geticoncolor.withAlpha(175)
      ) : null,
    ),
  );
}

Widget rectanglePictureContainer({
  required String label,
  IconData? icon,
  File? image,
  required void Function() onPressed
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 180,
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: notifire!.getMaingey,
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: FileImage(image ?? File("")),
            fit: BoxFit.cover
          )
        ),
        child: image == null ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FaIcon(
              icon ?? FontAwesomeIcons.idCard,
              size: 45,
              color: notifire!.geticoncolor.withAlpha(175)
            ),
            Text(label)
          ],
        ) : null,
      ),
    ),
  );
}