import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/image_viewer.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/provider/event.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool isLoading = true;

  Future<void> loadEvent(int eventId) async {
    try {
      await Provider.of<Event>(context, listen: false).eventDetail(eventId);
    } on HttpException {
      MessageService.showErrorMessage("Impossible de récupérer l'élément !");
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. vérifiez votre connexion internet",
      );
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendu est survenu !");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final int eventId = Get.arguments['eventId'];
      loadEvent(eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: SafeArea(child: ListShimmerPlaceholder()));
    }

    return Consumer<Event>(
      builder: (context, provider, child) {
        final event = provider.selectedEvent;
        return Scaffold(
          appBar:
              event == null
                  ? null
                  : AppBar(
                    leading: customBackButton(color: Colors.white),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                  ),
          extendBodyBehindAppBar: event != null,
          body:
              event == null
                  ? Center(child: CircularProgressIndicator(strokeWidth: 1.5))
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Partie de l'image et des titres
                      GestureDetector(
                        onTap:
                            () => Get.to(() =>
                              ImageViewer(imageUrl: event.imageUrl ?? ''),
                            ),
                        child: Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * .5,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  event.imageUrl == null
                                      ? AssetImage("assets/event.jpg")
                                      : FastCachedImageProvider(
                                        event.imageUrl!,
                                      ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(15),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withAlpha(200),
                                  Colors.black.withAlpha(70),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(15),
                              ),
                            ),
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Partie du contenu
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                event.description,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: notifire.getMainText),
                              ),
                            ),
                            displayingTile(
                              icon: FontAwesomeIcons.person,
                              text: "Organisateur",
                              child: Text(event.organizer),
                            ),
                            displayingTile(
                              icon: FontAwesomeIcons.solidCalendarDays,
                              text: "Période",
                              child: Row(
                                children: [
                                  Text(
                                    "Du ${formatDate(event.startDate)} au ${formatDate(event.endDate)}",
                                  ),
                                ],
                              ),
                            ),
                            displayingTile(
                              icon: FontAwesomeIcons.locationPin,
                              text: "Lieu",
                              child: Text(event.location),
                            ),
                            displayingTile(
                              icon: FontAwesomeIcons.ellipsisVertical,
                              text: "Type et catégorie",
                              child: Text("${event.type}, ${event.category}"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }

  Widget displayingTile({
    required IconData icon,
    required String text,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, size: 18, color: Colors.black),
              SizedBox(width: 10),
              Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          child,
        ],
      ),
    );
  }

  Widget customIconTitle(IconData icon, String text) {
    return Row(
      children: [
        FaIcon(icon, size: 18, color: Colors.black),
        SizedBox(width: 10),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
