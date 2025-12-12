import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/models/forum_comment.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ForumModel {
  late int id;
  late String title;
  late String body;
  late DateTime createdAt;
  late DateTime expiryDate;
  late bool isClosed;
  late bool isLiked;
  late int likes;
  List<ForumComment> comments = [];

  ForumModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['theme'];
    body = json['body'];
    createdAt = DateTime.parse(json['created_at']);
    expiryDate = DateTime.parse(json['date_expiration']);
    isClosed = json['is_closed'];
    isLiked = json['like'] ?? false;
    likes = json['total_likes'] ?? 0;
    json['commentaires_utilisateur'] != null
        ? json['commentaires_utilisateur']
            .map((e) => comments.add(ForumComment.fromJson(e)))
            .toList()
        : [];
  }

  Widget toTile(BuildContext context) {
    Color mainColor = isClosed ? notifire.warning : notifire.getMainColor;
    final textTheme = Theme.of(context).textTheme;
    
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.subject, arguments: {'id': id}),
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
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              // Icône avec badge de statut
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: mainColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      "assets/icons/forum.png",
                      height: 28,
                      width: 28,
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: mainColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: notifire.getContainer,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
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
                            title,
                            style: textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: notifire.getMainText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isClosed ? "Fermé" : "Ouvert",
                            style: textTheme.bodySmall!.copyWith(
                              color: mainColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: notifire.getbgcolor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          cusFaIcon(
                            FontAwesomeIcons.calendar,
                            size: 10,
                            color: notifire.getMainText.withOpacity(0.6),
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "Du ${formatDate(createdAt, withTime: false)} au ${formatDate(expiryDate, withTime: false)}",
                              style: textTheme.bodySmall!.copyWith(
                                color: notifire.getMainText.withOpacity(0.6),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notifire.getMainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 14,
                  color: notifire.getMainColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
