import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/image_viewer.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/components/tiles.dart';
import 'package:aesd/models/day_program.dart';
import 'package:aesd/models/servant_model.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart'
    show FastCachedImage, FastCachedImageProvider;
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
    'servant': mainServant,
  };

  Widget buildWidget(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap:
          () => {}, //Get.toNamed(Routes.postDetail, arguments: {'postId': id}),
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: notifire.getContainer,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(30),
              spreadRadius: 2,
              blurRadius: 3,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          children: [

            // image box
            SizedBox(
              height: 200,
              child: GestureDetector(
                onTap: () => Get.to(ImageViewer(imageUrl: image)),
                child: Stack(
                  children: [
                    Hero(
                      tag: image,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: FastCachedImage(
                          fit: BoxFit.cover,
                          url: image,
                          loadingBuilder: (context, progress) {
                            return imageShimmerPlaceholder(height: 200);
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      left: 5,
                      child: CircleAvatar(
                        backgroundColor: notifire.getContainer,
                        radius: 33,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: notifire.getMaingey,
                          backgroundImage: FastCachedImageProvider(logo!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de l'église
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      name,
                      style: textTheme.titleMedium!.copyWith(
                        color: notifire.getmaintext,
                      ),
                    ),
                  ),

                  // Adresse de l'église
                  infoTile(
                    context,
                    text: address,
                    icon: FontAwesomeIcons.locationDot,
                  ),

                  // Numéro de téléphone
                  infoTile(
                    context,
                    text: phone,
                    icon: FontAwesomeIcons.phone,
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
