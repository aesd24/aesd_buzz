import 'package:flutter/material.dart';

class UserModel {
  late int? id;
  late String name;
  late String email;
  late String phone;
  late String? photo;
  late String adress;
  late String accountType;
  late int? churchId;
  //late ChurchModel? church;

  static String get servant => "serviteur_de_dieu";
  static String get faithful => "fidele";
  static String get singer => "chantre";

  Widget tile(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap: () {},//Get.to(UserProfil(user: this)),
      leading: CircleAvatar(
        backgroundImage: photo != null ? NetworkImage(photo!) : null,
      ),
      title: Text(name, style: textTheme.labelMedium),
      subtitle: Text(
        email,
        style: textTheme.labelSmall!.copyWith(
          color: Colors.black.withAlpha(100)
        )
      ),
      trailing: accountType == 'serviteur_de_dieu' ? Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(3)
        ),
        child: Text(
          'Serviteur',
          style: textTheme.labelSmall!.copyWith(
            color: Colors.green
          ),
        ),
      ) : null,
    );
  }
  
  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'] ?? "";
    adress = json['adresse'] ?? "";
    phone = json['phone'] ?? "";
    photo = json['profile_photo'];
    accountType = json['account_type'];
    churchId = json['details'] == null ? null : json['details']['church_id'];
    //church = json['church'] == null ? null : ChurchModel.fromJson(json['church']);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'profile_photo_url': photo,
  };
}
