import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/image_viewer.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class NewsModel {
  late int id;
  late String title;
  late String content;
  late String? imageUrl;
  late DateTime date;

  NewsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['titre'];
    content = json['contenu'];
    imageUrl = json['image'];
    date = DateTime.parse(json['created_at']);
  }

  Widget buildWidget(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.newsDetail, arguments: {'newId': id}),
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: notifire.getContainer,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(30),
              spreadRadius: 2,
              blurRadius: 3,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // image box
            if (imageUrl != null)
              GestureDetector(
                onTap: () => Get.to(ImageViewer(imageUrl: imageUrl!)),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: FastCachedImage(
                    fit: BoxFit.cover,
                    url: imageUrl!,
                    loadingBuilder: (context, progress) {
                      return imageShimmerPlaceholder(height: 200);
                    },
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date de l'actualité
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        cusFaIcon(FontAwesomeIcons.calendar, size: 16),
                        SizedBox(width: 15),
                        Text(
                          formatDate(date),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // titre de l'actualité
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: notifire.getMainText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // contenu de l'actualité
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child:
                        content.length > 150
                            ? RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${content.substring(0, 150)}... ',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  TextSpan(
                                    text: 'Lire la suite',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Text(
                              content,
                              style: Theme.of(context).textTheme.bodyMedium,
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
