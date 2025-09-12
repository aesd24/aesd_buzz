import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/image_viewer.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/components/tiles.dart';
import 'package:aesd/models/day_program.dart';
import 'package:aesd/models/servant_model.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
  late DayProgramModel? program;

  ChurchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image =
        json['image'] ??
        'https://bretagneromantique.fr/wp-content/uploads/2021/04/IMG_4463-scaled.jpg';
    email = json['email'];
    logo = json['logo'];
    cover = json['cover_url'];
    address = json['adresse'];
    description = json['description'];
    phone = json['phone'];
    type = json['type_church'];
    mainServant =
        json['main_servant'] == null
            ? null
            : ServantModel.fromJson(json['main_servant']);
    mainServantId = json['owner_servant_id'];
    json['servants']?.forEach((d) {
      servants.add(ServantModel.fromJson(d));
    });
    program =
        json['program'] != null
            ? DayProgramModel.fromJson(json['program'])
            : null;
  }

  Widget buildWidget(
      BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => {},
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: notifire.getContainer,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: notifire.getMainColor.withAlpha(30),
              spreadRadius: 2,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // image box
            GestureDetector(
              onTap: () => Get.to(ImageViewer(imageUrl: image)),
              child: Hero(
                tag: image,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child: FastCachedImage(
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    url: image,
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
                    child: Text(
                      name,
                      style: textTheme.titleMedium!.copyWith(
                        color: notifire.getMainText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  //mainServant.buildTile(),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      textIconTile(
                        context,
                        FontAwesomeIcons.phone,
                        "(+225) $phone",
                      ),
                      textIconTile(context, FontAwesomeIcons.at, email),
                      textIconTile(context, FontAwesomeIcons.locationDot, address),
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
