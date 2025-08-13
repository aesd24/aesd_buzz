import 'package:flutter/material.dart';

class NewsModel {
  late int id;
  late String title;
  late String content;
  late String? imageUrl;
  late DateTime date;

  NewsModel.fromJson(json) {
    id = json['id'];
    title = json['titre'];
    content = json['contenu'];
    imageUrl = json['image'];
    date = DateTime.parse(json['created_at']);
  }

  Widget getWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {},//=> NavigationService.push(NewsPage(news: this)),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: imageUrl != null ? NetworkImage(imageUrl!) : AssetImage("assets/news.jpeg"),
            fit: BoxFit.cover
          )
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(colors: [
                Colors.black.withAlpha(200),
                Colors.black.withAlpha(75),
              ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          alignment: Alignment.bottomLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  title.length < 30 ? title : '${title.substring(0, 30)}...',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Text(
                content.length < 150 ? content : '${content.substring(0, 150)}...',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Colors.white70),
              )
            ],
          ),
        ),
      ),
    );
  }
}