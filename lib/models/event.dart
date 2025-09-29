import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/modal.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/components/tiles.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class EventModel {
  late int id;
  late String title;
  late String description;
  late DateTime startDate;
  late DateTime endDate;
  late String location;
  late String? imageUrl;
  late String type;
  late String category;
  late String organizer;
  late int churchId;
  late bool isPublic;

  EventModel.fromJson(json) {
    id = json['id'];
    title = json['titre'];
    description = json['description'];
    startDate = DateTime.parse(json['date_debut']);
    endDate = DateTime.parse(json['date_fin']);
    location = json['lieu'];
    imageUrl = json['file'];
    type = json['type_evenement'];
    category = json['categorie_evenement'];
    organizer = json['organisateur'];
    churchId = json['eglise_id'];
    isPublic = json['est_public'] == 1;
  }

  Widget buildWidget(BuildContext context, {Future Function(int)? onDelete}) {
    return InkWell(
      onTap: () => Get.toNamed(Routes.eventDetail, arguments: {'eventId': id}),
      child: Padding(
        padding: EdgeInsets.all(7),
        child: Container(
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
              if (imageUrl != null)
                GestureDetector(
                  onTap: () => showImageModal(context, imageUrl: imageUrl!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: FastCachedImage(
                      fit: BoxFit.cover,
                      url: imageUrl!,
                      loadingBuilder: (context, progress) {
                        return imageShimmerPlaceholder(height: 200);
                      },
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date et Lieu de l'évènement
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Wrap(
                        spacing: 10,
                        children: [
                          Row(
                            children: [
                              cusFaIcon(FontAwesomeIcons.locationDot),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  location,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              cusFaIcon(FontAwesomeIcons.calendarDay),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  "Du ${formatDate(startDate)} au ${formatDate(endDate)}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // titre de l'évènement
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(
                          color: notifire.getMainText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // contenu de l'évènement
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child:
                          description.length > 150
                              ? RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '${description.substring(0, 150)}... ',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                    TextSpan(
                                      text: 'Lire la suite',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Text(
                                description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
