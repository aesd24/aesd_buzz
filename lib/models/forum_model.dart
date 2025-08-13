import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/models/forum_comment.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    json['commentaires_utilisateur'] != null ?
    json['commentaires_utilisateur'].map(
      (e) => comments.add(ForumComment.fromJson(e))
    ).toList() : [];
  }

  Widget toTile(BuildContext context) {
    return Card(
      color: isClosed ? Colors.amber.shade50 : Colors.green.shade50,
      elevation: 0,
      child: ListTile(
        onTap: () {} /*=> NavigationService.push(
            DiscutionSubjectPage(subject: this)
        )*/,
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              "assets/icons/forum.png",
              height: 25,
              width: 25
            ),
            Positioned(
              right: -6,
              bottom: -6,
              child: CircleAvatar(
                radius: 6,
                backgroundColor: isClosed ? Colors.amber : Colors.green,
              )
            )
          ],
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
        ),
        subtitle: Text(
          "Du ${formatDate(createdAt)} au ${formatDate(expiryDate)}",
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: Colors.black54
          )
        ),
        trailing: FaIcon(FontAwesomeIcons.chevronRight, size: 16),
      ),
    );
  }
}
