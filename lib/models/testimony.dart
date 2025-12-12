import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class TestimonyModel {
  late int id;
  late String title;
  late bool isAnonymous;
  late String mediaType;
  late String mediaUrl;
  late UserModel? user;
  late DateTime date;

  TestimonyModel.fromJson(json) {
    id = json['id'];
    title = json['title'];
    isAnonymous = json['is_anonymous'] == 1;
    mediaUrl = json['confession_file_path'];
    mediaType = json['type'];
    user = json['user'] == null ? null : UserModel.fromJson(json['user']);
    date = DateTime.parse(json['published_at']);
  }

  Widget buildWidget(BuildContext context) {
    Color boxColor = mediaType == 'audio' ? Colors.blue : Colors.purple;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.testimonyDetail, arguments: {'id': id}),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: notifire.getContainer,
          borderRadius: BorderRadius.circular(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec badge audio/vidéo
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    boxColor.withOpacity(0.15),
                    boxColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: boxColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: cusFaIcon(
                      mediaType == 'audio'
                          ? FontAwesomeIcons.music
                          : FontAwesomeIcons.film,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mediaType == 'audio' ? 'Témoignage audio' : 'Témoignage vidéo',
                          style: textTheme.titleSmall!.copyWith(
                            color: boxColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: notifire.getbgcolor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            getPostFormattedDate(date),
                            style: textTheme.bodySmall!.copyWith(
                              color: notifire.getMainText.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    title,
                    style: textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: notifire.getMainText,
                      height: 1.3,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Auteur ou Anonyme
                  Row(
                    children: [
                      if (user != null)
                        user!.buildTile()
                      else
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: notifire.getbgcolor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              cusFaIcon(
                                FontAwesomeIcons.userSecret,
                                size: 12,
                                color: notifire.getMainText.withOpacity(0.6),
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Anonyme",
                                style: textTheme.bodySmall!.copyWith(
                                  color: notifire.getMainText.withOpacity(0.6),
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getWidget(BuildContext context) {
    Color boxColor = mediaType == 'audio' ? Colors.blue : Colors.purple;
    return GestureDetector(
      onTap: () {} /*=> NavigationService.push(
        TestimonyDetail(testimony: this)
      )*/,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(7),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(width: 1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            user != null
                ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundImage:
                            user?.photo != null
                                ? NetworkImage(user!.photo!)
                                : null,
                      ),
                      SizedBox(width: 10),
                      Text(
                        user!.name,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                )
                : Text(
                  "Anonyme",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
            Container(
              margin: EdgeInsets.only(top: 22, bottom: 10),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                border: Border.all(color: boxColor, width: 1),
                borderRadius: BorderRadius.circular(10),
                color: boxColor.withAlpha(30),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: boxColor,
                  child: FaIcon(
                    mediaType == 'audio'
                        ? FontAwesomeIcons.music
                        : FontAwesomeIcons.clapperboard,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
                title: Text(
                  'Témoignage ${mediaType == 'audio' ? 'audio' : 'vidéo'}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: boxColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
