import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/models/user_model.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ServantModel {
  late int id;
  late bool isMain;
  late Type call;
  late UserModel? user;
  late ChurchModel? church;

  ServantModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isMain = json['is_main'] == 1;
    call = Dictionnary.servantCalls.firstWhere(
      (element) => element.code == json['appel'],
    );
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
    church =
        json['church'] != null ? ChurchModel.fromJson(json['church']) : null;
  }

  Widget buildCard(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Get.toNamed(
            Routes.profil,
            arguments: {'user': user, 'servantId': id},
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
                          user!.photo != null
                              ? FastCachedImageProvider(user!.photo!)
                              : null,
                      child:
                          user!.photo != null
                              ? null
                              : cusFaIcon(
                                FontAwesomeIcons.solidUser,
                                color: notifire.getbgcolor,
                              ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(user!.name, overflow: TextOverflow.clip),
                    ),
                  ],
                ),

                if (isMain)
                  Row(
                    children: [
                      Text(
                        "Principale",
                        style: TextStyle(color: notifire.warning),
                      ),
                      SizedBox(width: 5),
                      cusFaIcon(
                        FontAwesomeIcons.solidStar,
                        color: notifire.warning,
                      ),
                    ],
                  ),
              ],
            ),

            SizedBox(height: 7),

            Text(
              call.name,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: notifire.getMainText.withAlpha(150),
              ),
            ),
            if (church != null)
              Text(
                church!.name,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: notifire.getMaingey),
              ),
          ],
        ),
      ),
    );
  }

  Widget card(BuildContext context) {
    //ColorScheme themeColors = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {} /*=> NavigationService.push(UserProfil(
        user: user,
        servantId: id,
      ))*/,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // zone de présentation du serviteur
            Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundImage:
                      user!.photo != null ? NetworkImage(user!.photo!) : null,
                ),
                SizedBox(width: 13),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user!.name, style: textTheme.titleMedium),
                    Row(
                      children: [
                        Text("Serviteur"),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: CircleAvatar(
                            radius: 3,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        Text(
                          call.name,
                          style: textTheme.bodySmall!.copyWith(
                            color: Colors.black.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            /* if(church != null) Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.church, size: 20),
                  SizedBox(width: 10),
                  Text(church!.name, style: textTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.bold
                  )),
                ],
              )
            ) */
          ],
        ),
      ),
    );
  }
}
