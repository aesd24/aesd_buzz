import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/modal.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/components/tiles.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  Widget buildWidget(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.all(7),
      child: Container(
        decoration: BoxDecoration(
          color: notifire.getcontiner,
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
                            SizedBox(width: 5),
                            Text(
                              location,
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            cusFaIcon(FontAwesomeIcons.calendarDay),
                            SizedBox(width: 5),
                            Text(
                              "Du ${formatDate(startDate)} au ${formatDate(endDate)}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),

                  // titre de l'évènement
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  // contenu de l'évènement
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child:
                        description.length > 150
                            ? RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${description.substring(0, 150)}... ',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
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
    );
  }

  Widget getWidget(
    BuildContext context, {
    bool adminMode = false,
    Future Function(int id)? onDelete,
  }) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {}, //=> NavigationService.push(EventPage(event: this)),
      child: Container(
        width: size.width * .9,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image:
                imageUrl == null
                    ? const AssetImage("assets/event.jpg")
                    : NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.green.withAlpha(180), Colors.green.withAlpha(80)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (adminMode)
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {} /*=> NavigationService.push(
                        EventForm(
                          churchId: churchId,
                          editMode: true,
                          event: this,
                        )
                      )*/,
                        icon: FaIcon(FontAwesomeIcons.pen, size: 18),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.amber),
                          iconColor: WidgetStatePropertyAll(Colors.white),
                        ),
                      ),
                      /*IconButton(
                      onPressed: () => messageBox(
                        context,
                        title: 'Supprimer ?',
                        content: Text("Vous allez supprimer cet événement. Voulez-vous continuer ?"),
                        actions: [
                          TextButton(
                            onPressed: () => NavigationService.close(),
                            style: ButtonStyle(
                              foregroundColor: WidgetStatePropertyAll(Colors.grey),
                            ),
                            child: Text("Annuler"),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              NavigationService.close();
                              onDelete!(id);
                            },
                            style: ButtonStyle(
                              foregroundColor: WidgetStatePropertyAll(Colors.red),
                              overlayColor: WidgetStatePropertyAll(Colors.red.shade100),
                              iconColor: WidgetStatePropertyAll(Colors.red)
                            ),
                            label: Text("Supprimer"),
                            icon: FaIcon(FontAwesomeIcons.trashCan, size: 18),
                            iconAlignment: IconAlignment.end,
                          ),
                        ]
                      ),
                      icon: FaIcon(FontAwesomeIcons.trashCan, size: 18),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red),
                        iconColor: WidgetStatePropertyAll(Colors.white)
                      ),
                    )*/
                    ],
                  ),
                ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "Du ${formatDate(startDate)} au ${formatDate(endDate)}",
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
