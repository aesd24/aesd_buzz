import 'package:aesd/models/church_model.dart';
import 'package:aesd/models/user_model.dart';
import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServantModel {
  late int id;
  late bool isMain;
  late String call;
  late UserModel user;
  late ChurchModel? church;

  ServantModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isMain = json['is_main'] == 1;
    call = json['appel'];
    user = UserModel.fromJson(json['user']);
    church = json['church'] != null ? ChurchModel.fromJson(json['church']) : null;
  }

  Widget card(BuildContext context){
    //ColorScheme themeColors = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {} /*=> NavigationService.push(UserProfil(
        user: user,
        servantId: id,
      ))*/,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Colors.grey))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // zone de présentation du serviteur
            Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundImage: user.photo != null ?
                    NetworkImage(user.photo!) : null
                ),
                SizedBox(width: 13),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: textTheme.titleMedium),
                    Row(
                      children: [
                        Text("Serviteur"),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: CircleAvatar(radius: 3, backgroundColor: Colors.grey),
                        ),
                        Text(call, style: textTheme.bodySmall!.copyWith(
                          color: Colors.black.withAlpha(150)
                        )),
                      ],
                    ),
                  ],
                ),
              ],
            ),
      
            /* if(church != null) Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.church, size: 20),
                  SizedBox(width: 10),
                  Text(church!.name, style: textTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.bold
                  )),
                ],
              )
            ) */
          ],
        ),
      ),
    );
  }
}
