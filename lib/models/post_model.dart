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
  late UserModel author;
  late DateTime date;
  bool liked = false;
  late int comments;
  late int likes;

  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['contenu'];
    image = json['image'];
    author = UserModel.fromJson(json['user']);
    date = DateTime.parse(json['created_at']);
    liked = json['liked'] ?? false;
    comments = json['comments_count'];
    likes = json['likes_count'];
  }

  Widget buildWidget(
    BuildContext context, {
    required void Function(PostModel post) onLike,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.postDetail, arguments: {'postId': id}),
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
            if (image != null)
              GestureDetector(
                onTap: () => Get.to(ImageViewer(imageUrl: image!)),
                child: Hero(
                  tag: image!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: FastCachedImage(
                      fit: BoxFit.cover,
                      url: image!,
                      loadingBuilder: (context, progress) {
                        return imageShimmerPlaceholder(height: 200);
                      },
                    ),
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contenu du post
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child:
                        content.length > 150
                            ? RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${content.substring(0, 150)}... ',
                                    style: textTheme.bodyMedium,
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
                            : Text(content, style: textTheme.bodyMedium),
                  ),

                  // Poster par... / le ...
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      author.buildTile(),
                      Text(
                        getPostFormattedDate(date),
                        style: textTheme.bodySmall!.copyWith(
                          color: scheme.onSurface.withAlpha(100),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // likes / comments (actions)
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      customActionButton(
                        onPressed: () => onLike(this),
                        cusFaIcon(
                          liked
                              ? FontAwesomeIcons.solidHeart
                              : FontAwesomeIcons.heart,
                          color: liked ? Colors.red : notifire.getMainText,
                        ),
                        likes == 0 ? "J'aime" : likes.toString(),
                      ),
                      SizedBox(width: 15),
                      customActionButton(
                        cusFaIcon(
                          FontAwesomeIcons.comment,
                          color: notifire.getMainText,
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
