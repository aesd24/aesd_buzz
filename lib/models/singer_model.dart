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
        padding: EdgeInsets.all(18),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: notifire.getContainer,
          boxShadow: [
            BoxShadow(
              color: notifire.getMainColor.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar avec bordure moderne
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: notifire.getMainColor.withOpacity(0.3),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: notifire.getMainColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: notifire.getMainColor.withOpacity(0.1),
                backgroundImage:
                    user.photo != null
                        ? FastCachedImageProvider(user.photo!)
                        : null,
                child:
                    user.photo != null
                        ? null
                        : cusFaIcon(
                          FontAwesomeIcons.solidUser,
                          color: notifire.getMainColor,
                          size: 20,
                        ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: notifire.getMainText,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: notifire.getMainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        cusFaIcon(
                          FontAwesomeIcons.music,
                          size: 10,
                          color: notifire.getMainColor,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Chantre",
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: notifire.getMainColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
