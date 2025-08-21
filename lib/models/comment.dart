import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/models/user_model.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommentModel {
  late int id;
  late String content;
  late UserModel owner;
  late DateTime date;
  late String? imageUrl;
  late int views;

  CommentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['comment'];
    owner = UserModel.fromJson(json['user']);
    date = DateTime.parse(json['created_at']);
    imageUrl = json['image'];
    views = json['nombre_vue'] ?? 0;
  }

  Widget buildWidget(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: notifire.getMaingey, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: notifire.getMainColor,
            backgroundImage:
                owner.photo != null
                    ? FastCachedImageProvider(owner.photo!)
                    : null,
            child:
                owner.photo != null
                    ? null
                    : cusFaIcon(
                      FontAwesomeIcons.solidUser,
                      color: notifire.getbgcolor,
                    ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // partie du owner et de la date
                Wrap(
                  spacing: 10,
                  children: [
                    Text(
                      owner.name,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: notifire.getMainText
                      ),
                    ),
                    Text(
                      getPostFormattedDate(date),
                      style: textTheme.bodySmall!.copyWith(
                        color: scheme.onSurface.withAlpha(100),
                      ),
                    )
                  ]
                ),

                // partie du contenu
                SizedBox(height: 4),
                Text(content),

                // Nombre de vues
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(views.toString(), style: textTheme.bodySmall),
                    SizedBox(width: 5),
                    cusFaIcon(FontAwesomeIcons.eye, size: 13)
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
