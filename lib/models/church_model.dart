import 'package:aesd/models/day_program.dart';
import 'package:aesd/models/servant_model.dart';
import 'package:flutter/material.dart';

class ChurchModel {
  late int id;
  late String name;
  late String phone;
  late String email;
  late String address;
  late String description;
  late String? logo;
  late String? cover;
  late String image;
  late String? type;
  late List<ServantModel> servants = [];
  late ServantModel? mainServant;
  late int mainServantId;
  late DayProgramModel? programm;

  ChurchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'] ??
        'https://bretagneromantique.fr/wp-content/uploads/2021/04/IMG_4463-scaled.jpg';
    email = json['email'];
    logo = json['logo'];
    cover = json['cover_url'];
    address = json['adresse'];
    description = json['description'];
    phone = json['phone'];
    type = json['type_church'];
    mainServant = json['main_servant'] == null
        ? null
        : ServantModel.fromJson(json['main_servant']);
    mainServantId = json['owner_servant_id'];
    json['servants']?.forEach((d) {
      servants.add(ServantModel.fromJson(d));
    });
    programm = json['program'] != null
        ? DayProgramModel.fromJson(json['program'])
        : null;
  }

  toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'email': email,
    'logo_url': logo,
    'cover_url': cover,
    'adresse': address,
    'description': description,
    'phone': phone,
    'servant': mainServant
  };

  Widget card(BuildContext context) {
    String elipsedAdress = address.length > 10 ? '${address.substring(0, 10)}...' : address;
    String elipsedEmail = email.length > 20 ? '${email.substring(0, 20)}...' : email;
    return Container(
      width: double.infinity,
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.black.withOpacity(.8),
            Colors.black.withOpacity(.1)
          ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      elipsedEmail,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.location_pin,
                            color: Colors.white60, size: 18),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            elipsedAdress,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: Colors.white60,
                                ),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChurchPaginator {
  late List<ChurchModel> churches;
  late int currentPage;
  late int totalPages;

  ChurchPaginator.fromJson(Map<String, dynamic> json) {
    churches =
        (json['churches'] as List).map((e) => ChurchModel.fromJson(e)).toList();
    currentPage = json['current_page'] ?? 0;
    totalPages = json['total_pages'] ?? 1;
  }
}
