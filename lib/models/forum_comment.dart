import 'package:aesd/functions/formatteurs.dart';
import 'package:flutter/material.dart';

class ForumComment {
  late String ownerName;
  late String content;
  late DateTime date;
  late String? ownerProfilePhotoUrl;

  ForumComment.fromJson(Map<String, dynamic> json) {
    ownerName = json['name'];
    content = json['commentaire'];
    date = DateTime.parse(json['comment_created_at']);
    ownerProfilePhotoUrl = json['profile_photo'];
  }

  Widget getWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              offset: Offset(0, -1),
              color: Theme.of(context).colorScheme.tertiary.withAlpha(70)
            ),
            BoxShadow(
              blurRadius: 2,
              offset: Offset(1, 3),
              color: Theme.of(context).colorScheme.tertiary.withAlpha(70)
            )
          ],
          border: Border(
            left: BorderSide(
              width: 5,
              color: Theme.of(context).colorScheme.secondary
            )
          ),
          borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ownerName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    formatDate(date),
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Colors.black54
                    ),
                  )
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium
            ),
          )
        ],
      ),
    );
  }
}