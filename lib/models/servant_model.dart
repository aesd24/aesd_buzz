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
      onTap: () => Get.toNamed(Routes.profil, arguments: {'userId': user!.id}),
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
                    user!.photo != null
                        ? FastCachedImageProvider(user!.photo!)
                        : null,
                child:
                    user!.photo != null
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user!.name,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: notifire.getMainText,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMain)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: notifire.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              cusFaIcon(
                                FontAwesomeIcons.solidStar,
                                color: notifire.warning,
                                size: 10,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Principal",
                                style: TextStyle(
                                  color: notifire.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: notifire.getMainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      call.name,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: notifire.getMainColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (church != null) ...[
                    SizedBox(height: 6),
                    Row(
                      children: [
                        cusFaIcon(
                          FontAwesomeIcons.church,
                          size: 10,
                          color: notifire.getMainText.withOpacity(0.6),
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            church!.name,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: notifire.getMainText.withOpacity(0.6),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
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
