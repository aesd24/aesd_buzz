import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/certification_banner.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/image_viewer.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/models/day_program.dart';
import 'package:aesd/models/servant_model.dart';
import 'package:aesd/models/user_model.dart';
import 'package:aesd/pages/dashboard/retryChurchValidity.dart';
import 'package:aesd/pages/social/church/detail.dart';
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
  late String? validationState;
  List<ServantModel> servants = [];
  ServantModel? owner;
  List<UserModel> members = [];
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
    validationState = json['validation_status'];
    json['servants']?.forEach((d) {
      servants.add(ServantModel.fromJson(d));
    });
  }

  Widget buildWidget(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap:
          () => Get.to(() => ChurchDetailPage(), arguments: {'churchId': id}),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: notifire.getContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: notifire.getMainColor.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image box
            GestureDetector(
              onTap: () => Get.to(ImageViewer(imageUrl: logo ?? "")),
              child: Hero(
                tag: logo ?? "",
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      FastCachedImage(
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        url: logo ?? "",
                        loadingBuilder: (context, progress) {
                          return imageShimmerPlaceholder(height: 220);
                        },
                      ),
                      // Overlay gradient pour un effet moderne
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Nom de l'église sur l'image
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Text(
                          name,
                          style: textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations de contact avec style moderne
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        context,
                        FontAwesomeIcons.phone,
                        "(+225) $phone",
                      ),
                      _buildInfoChip(
                        context,
                        FontAwesomeIcons.at,
                        email,
                      ),
                      _buildInfoChip(
                        context,
                        FontAwesomeIcons.locationDot,
                        address,
                      ),
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

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: notifire.getMainColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notifire.getMainColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          cusFaIcon(
            icon,
            size: 12,
            color: notifire.getMainColor,
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: notifire.getMainText,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildValidationChurchBanner(BuildContext context) {
    BannerType? banner;
    if (validationState == "pending") {
      banner = BannerType.waitingBanner.copyWith(
        text: "En attente de validation",
      );
    } else if (validationState == "rejected") {
      banner = BannerType.rejectedBanner.copyWith(
        text: "Réfusé, cliquez pour rééssayer",
      );
    }
    return GestureDetector(
      onTap: () {
        if (validationState == "rejected") {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) {
              return RetryValidateChurch(churchId: id);
            },
          );
        }
      },
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: banner!.color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: cusFaIcon(banner.icon, color: banner.color),
          title: Text(
            banner.text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: banner.color),
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
