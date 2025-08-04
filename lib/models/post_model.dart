import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  getWidget(
    BuildContext context, {
    required Future Function(PostModel post) onLike,
  }) {
    return GestureDetector(
      onTap: () {} /*=> NavigationService.push(
        SinglePost(
          post: this,
        )
      )*/,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: author.photo != null ?
                        NetworkImage(author.photo!) : null,
                    ),
                    SizedBox(width: 10),
                    Text(
                      author.name,
                      style: Theme.of(context).textTheme.titleMedium
                    )
                  ],
                ),
                Text(
                  formatDate(date),
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Colors.grey
                  ),
                )
              ],
            ),

            // Contenu du post
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: content.length > 150 ? RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${content.substring(0, 150)}... ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextSpan(
                      text: 'Lire la suite',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)
                    )
                  ]
                )
              ) : Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            ),

            // Image contenu dans le post
            if (image != null) Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withAlpha(100),
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(image!), fit: BoxFit.cover
                  )
                ),
              )
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 20),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => onLike(this),
                    icon: FaIcon(
                      liked
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      color: liked ? Colors.red : Colors.black,
                    ),
                    label: Text("$likes likes"),
                    style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(Colors.black),
                        overlayColor:
                            WidgetStateProperty.all(Colors.grey.shade200)),
                  ),
                  const SizedBox(width: 50),
                  TextButton.icon(
                    onPressed: () {}, //=> NavigationService.push(SinglePost(post: this, isCommenting: true)),
                    icon: const FaIcon(
                      FontAwesomeIcons.comment,
                    ),
                    label: Text("$comments commentaires"),
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.black),
                      iconColor: WidgetStateProperty.all(Colors.black),
                      overlayColor: WidgetStateProperty.all(Colors.grey.shade200)
                    ),
                  )
                ],
              ),
            )
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
    posts =
        (json['posts'] as List).map((e) => PostModel.fromJson(e)).toList();
    currentPage = json['current_page'] ?? 0;
    totalPages = json['total_pages'] ?? 1;
  }
}