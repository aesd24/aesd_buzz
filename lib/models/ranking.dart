import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

class RankingModel {
  late int userId;
  late String userName;
  late String userPicUrl;
  late int rank;
  late int score;
  String? timeElapsed;

  RankingModel.globalFromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['name'];
    userPicUrl = json['profile_photo_url'];
    rank = json['rang'];
    score = int.parse(json['total_score']);
  }

  RankingModel.singleFromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['name'];
    userPicUrl = json['profile_photo_url'];
    rank = json['rang'];
    score = int.parse(json['score']);
    timeElapsed = json['time_remaining'];
  }

  Widget buildWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: notifire.getContainer,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: notifire.getMaingey.withAlpha(75),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: notifire.getMaingey,
              backgroundImage: FastCachedImageProvider(userPicUrl),
            ),
            title: Text(
              userName,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: notifire.getMainText.withAlpha(200),
              ),
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 15,
              runSpacing: 10,
              children: [
                buildDisplayContainer(
                  context,
                  label: "Rang",
                  assetName: 'podium',
                  value: rank.toString(),
                ),
                buildDisplayContainer(
                  context,
                  label: "Score",
                  assetName: 'target',
                  value: score.toString(),
                  color: notifire.danger,
                ),
                if (timeElapsed != null)
                  buildDisplayContainer(
                    context,
                    label: "Temps",
                    assetName: 'clock',
                    color: Colors.deepPurple,
                    value: timeElapsed!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container buildDisplayContainer(
    BuildContext context, {
    required String label,
    required String value,
    required String assetName,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color ?? notifire.info, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
            decoration: BoxDecoration(
              color: color ?? notifire.info,
              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/icons/$assetName.png",
                  height: 25,
                  width: 25,
                ),
                SizedBox(width: 5),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: notifire.getMainText),
            ),
          ),
        ],
      ),
    );
  }
}
