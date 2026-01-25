import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aesd/models/user_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SingerModel {
  late String manager;
  late String description;
  late String phone;
  late UserModel user;

  SingerModel.fromJson(Map<String, dynamic> json) {
    manager = json['manager'];
    description = json['description'];
    user = UserModel.fromJson(json['user']);
  }

  Widget buildCard(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Get.toNamed(
        Routes.profil,
        arguments: {'user': user},
      ),
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: notifire.getbgcolor,
          boxShadow: [
            BoxShadow(
              color: notifire.getMaingey,
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: notifire.getMainColor,
                      backgroundImage:
                      user.photo != null
                          ? FastCachedImageProvider(user.photo!)
                          : null,
                      child:
                      user.photo != null
                          ? null
                          : cusFaIcon(
                        FontAwesomeIcons.solidUser,
                        color: notifire.getbgcolor,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(user.name, overflow: TextOverflow.clip),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
