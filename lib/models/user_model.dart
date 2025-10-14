import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/models/servant_model.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'church_model.dart';

class UserModel {
  late int id;
  late String name;
  late String email;
  late String phone;
  late String? photo;
  late String adress;
  late Type accountType;
  late String? certifStatus;
  late DateTime? certifiedAt;
  late ChurchModel? church;
  late ServantModel? servant;

  Widget buildWidget(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
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
      child: ListTile(
        onTap: () {}, //Get.to(UserProfil(user: this)),
        leading: CircleAvatar(
          backgroundImage:
              photo != null ? FastCachedImageProvider(photo!) : null,
        ),
        title: Text(name.length > 25 ? "${name.substring(0, 25)}..." : name),
        subtitle: Text(
          email,
          style: textTheme.bodySmall!.copyWith(color: notifire.getMaingey),
          overflow: TextOverflow.clip,
        ),
        trailing:
            accountType.code == Dictionnary.servant.code
                ? Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: notifire.getMainColor),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'Serviteur',
                    style: textTheme.labelSmall!.copyWith(
                      color: notifire.getMainColor,
                    ),
                  ),
                )
                : null,
      ),
    );
  }

  Widget buildTile() {
    return Row(
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
    );
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    adress = json['adresse'];
    phone = json['phone'];
    photo = json['profile_photo'];
    servant =
        json['servant'] != null ? ServantModel.fromJson(json['details']) : null;
    accountType = Dictionnary.accountTypes.firstWhere(
      (element) => element.code == json['account_type'],
    );
    church =
        json['church'] == null ? null : ChurchModel.fromJson(json['church']);
    if (json['details'] != null) {
      certifStatus = json['details']['certif_status'];
      certifiedAt =
          json['details']['certified_at'] != null
              ? DateTime.parse(json['details']['certified_at'])
              : null;
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
