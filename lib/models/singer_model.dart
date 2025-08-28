import 'package:flutter/material.dart';
import 'package:aesd/models/user_model.dart';

class SingerModel {
  late String manager;
  late String description;
  late String phone;
  late UserModel user;

  SingerModel.fromJson(Map<String, dynamic> json) {
    manager = json['manager'];
    description = json['description'];
    user = UserModel.fromJson(json['user']);
  }

  Widget card(BuildContext context){
    TextTheme textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {},//=> NavigationService.push(UserProfil(user: user)),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Colors.black))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // zone de présentation du serviteur
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 30,),
                SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: textTheme.titleMedium),
                    Text(
                      "manager: $manager",
                      style: textTheme.bodySmall!.copyWith(
                        color: Colors.black.withAlpha(150)
                      )
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
