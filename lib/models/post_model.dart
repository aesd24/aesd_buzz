import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/image_viewer.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/models/user_model.dart';
import 'package:aesd/pages/social/posts/comments.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class PostModel {
  late int id;
  late String content;
  late String? image;
  late UserModel? author;
  late DateTime date;
  bool liked = false;
  late int comments;
  late int likes;

  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['contenu'];
    image = json['image'];
    author = json['user'] != null ? UserModel.fromJson(json['user']) : null;
    date = DateTime.parse(json['created_at']);
    liked = json['liked'] ?? false;
    comments = json['comments_count'];
    likes = json['likes_count'];
  }

  Widget buildWidget(
    BuildContext context, {
     void Function(PostModel post)? onLike,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.postDetail, arguments: {'postId': id}),
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
            if (image != null)
              GestureDetector(
                onTap: () => Get.to(ImageViewer(imageUrl: image!)),
                child: Hero(
                  tag: image!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        FastCachedImage(
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          url: image!,
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
              ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contenu du post
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child:
                        content.length > 150
                            ? RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${content.substring(0, 150)}... ',
                                    style: textTheme.bodyMedium!.copyWith(
                                      color: notifire.getMainText.withOpacity(0.8),
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
                              style: textTheme.bodyMedium!.copyWith(
                                color: notifire.getMainText.withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                  ),

                  // Divider élégant
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          notifire.getMainColor.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Poster par... / le ...
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (author != null) author!.buildTile(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: notifire.getbgcolor,
                          borderRadius: BorderRadius.circular(12),
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

                  SizedBox(height: 16),

                  // likes / comments (actions) avec style moderne
                  if (onLike != null) Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: notifire.getbgcolor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: customActionButton(
                            onPressed: () => onLike(this),
                            cusFaIcon(
                              liked
                                  ? FontAwesomeIcons.solidHeart
                                  : FontAwesomeIcons.heart,
                              color: liked ? Colors.red : notifire.getMainColor,
                            ),
                            likes == 0 ? "J'aime" : likes.toString(),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: notifire.getMaingey.withOpacity(0.3),
                        ),
                        Expanded(
                          child: customActionButton(
                            cusFaIcon(
                              FontAwesomeIcons.comment,
                              color: notifire.getMainColor,
                            ),
                            comments == 0 ? "Commenter" : comments.toString(),
                            onPressed:
                                () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return CommentPages(postId: id);
                                  },
                                ),
                          ),
                        ),
                      ],
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

class PostPaginator {
  late List<PostModel> posts;
  int currentPage = 0;
  int totalPages = 1;

  PostPaginator();

  PostPaginator.fromJson(Map<String, dynamic> json) {
    posts = (json['posts'] as List).map((e) => PostModel.fromJson(e)).toList();
    currentPage = json['current_page'] ?? 0;
    totalPages = json['total_pages'] ?? 1;
  }
}
