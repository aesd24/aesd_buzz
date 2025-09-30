import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class UserModel {
  late int? id;
  late String name;
  late String email;
  late String phone;
  late String? photo;
  late String adress;
  late Type accountType;
  late int? churchId;
  late String? certifStatus;
  late DateTime? certifiedAt;
  //late ChurchModel? church;

  Widget buildWidget(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap: () {}, //Get.to(UserProfil(user: this)),
      leading: CircleAvatar(
        backgroundImage: photo != null ? FastCachedImageProvider(photo!) : null,
      ),
      title: Text(name, style: textTheme.labelMedium),
      subtitle: Text(
        email,
        style: textTheme.labelSmall!.copyWith(
          color: Colors.black.withAlpha(100),
        ),
      ),
      trailing:
          accountType.code == Dictionnary.servant.code
              ? Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'Serviteur',
                  style: textTheme.labelSmall!.copyWith(color: Colors.green),
                ),
              )
              : null,
    );
  }

  Widget buildTile() {
    return GestureDetector(
      onTap:
          () => Get.toNamed(
            Routes.profil,
            arguments: {
              'user': this,
              'servantId': accountType == Dictionnary.servant ? id : null,
            },
          ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: notifire.getMainColor,
            backgroundImage:
                photo != null ? FastCachedImageProvider(photo!) : null,
            child:
                photo != null
                    ? null
                    : cusFaIcon(
                      FontAwesomeIcons.solidUser,
                      color: notifire.getbgcolor,
                    ),
          ),
          SizedBox(width: 10),
          Text(name),
        ],
      ),
    );
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'] ?? "";
    adress = json['adresse'] ?? "";
    phone = json['phone'] ?? "";
    photo = json['profile_photo'];
    accountType = Dictionnary.accountTypes.firstWhere(
      (element) => element.code == json['account_type'],
    );
    if (json['details'] != null) {
      certifStatus = json['details']['certif_status'];
      certifiedAt =
          json['details']['certified_at'] != null
              ? DateTime.parse(json['details']['certified_at'])
              : null;
      churchId = json['details']['church_id'];
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'profile_photo_url': photo,
  };
}
