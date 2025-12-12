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
            // image box
            if (imageUrl != null)
              GestureDetector(
                onTap: () => Get.to(ImageViewer(imageUrl: imageUrl!)),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      FastCachedImage(
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        url: imageUrl!,
                        loadingBuilder: (context, progress) {
                          return imageShimmerPlaceholder(height: 220);
                        },
                      ),
                      // Overlay gradient pour un effet moderne
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date de l'actualité avec style moderne
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: notifire.getMainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        cusFaIcon(
                          FontAwesomeIcons.calendar,
                          size: 12,
                          color: notifire.getMainColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          formatDate(date),
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: notifire.getMainColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // titre de l'actualité
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: notifire.getMainText,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 12),

                  // contenu de l'actualité
                  content.length > 150
                      ? RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${content.substring(0, 150)}... ',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: notifire.getMainText.withOpacity(0.7),
                                  height: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: 'Lire la suite',
                                style: TextStyle(
                                  color: notifire.getMainColor,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          content,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: notifire.getMainText.withOpacity(0.7),
                            height: 1.5,
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
