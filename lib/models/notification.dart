import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationModel {
  late int id;
  late String title;
  late String content;
  late DateTime date;
  late bool readed;
  late String type;

  NotificationModel.fromJson(json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    date = json['date'];
    readed = json['readed'] == 1 ? true : false;
    type = json['notificationType'];
  }

  getTile(context) => Card(
        elevation: 0,
        color: readed ? Colors.grey.shade100 : Colors.green.shade200,
        shape: !readed
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.green.shade700, width: 2))
            : null,
        child: ListTile(
          onTap: () {}, // => NavigationService.push(NotificationDetail(notification: this)),
          leading: CircleAvatar(
              backgroundColor: readed ? Colors.grey.shade400 : Colors.white,
              child: const FaIcon(FontAwesomeIcons.solidBell)),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text("${date.day}/${date.month}/${date.year}"),
        ),
      );
}
