import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
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
    Color mainColor = isClosed ? notifire.warning : notifire.success;
    return Card(
      color: notifire.getContainer,
      shadowColor: mainColor.withAlpha(100),
      elevation: 4,
      child: ListTile(
        onTap: () => Get.toNamed(Routes.subject, arguments: {'id': id}),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: mainColor,
              child: CircleAvatar(
                radius: 21,
                backgroundColor: notifire.getContainer,
                child: Image.asset(
                  "assets/icons/forum.png",
                  height: 25,
                  width: 25,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 6,
                backgroundColor: mainColor,
              ),
            ),
          ],
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          "Du ${formatDate(createdAt, withTime: false)} au ${formatDate(expiryDate, withTime: false)}",
          style: Theme.of(
            context,
          ).textTheme.labelMedium!.copyWith(color: Colors.black54),
        ),
        trailing: FaIcon(FontAwesomeIcons.chevronRight, size: 16),
      ),
    );
  }
}
