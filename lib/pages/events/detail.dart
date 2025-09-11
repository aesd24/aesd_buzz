import 'dart:io';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/models/event.dart';
import 'package:aesd/provider/event.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key, this.event});

  final EventModel? event;

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool isLoading = false;
  EventModel? event;

  loadEvent(int eventId) async {
    try {
      await Provider.of<Event>(context, listen: false).eventDetail(
          eventId
      ).then((value) {
        event = Provider.of<Event>(context, listen: false).selectedEvent;
      });
    } on HttpException {
      MessageService.showErrorMessage("Impossible de récupérer l'élément !");
    } on DioException {
      MessageService.showErrorMessage("Erreur réseau. vérifiez votre connexion internet");
    } catch(e) {
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
    setState(() {
      isLoading = true;
    });
    if (widget.event != null) {
      event = widget.event;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (event == null) {
        int eventId = ModalRoute.of(context)!.settings.arguments as int;
        await loadEvent(eventId);
      }
      setState(() {
        isLoading = false;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: event == null ? null : AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Image.asset("assets/event.jpg", fit: BoxFit.contain),
                  ),
                );
              },
            ),
            icon: const FaIcon(
              FontAwesomeIcons.expand,
              size: 20,
            ),
            iconAlignment: IconAlignment.end,
            label: Text(
              "Affiche",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.white
              ),
            ),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              iconColor: WidgetStateProperty.all(Colors.white),
              overlayColor: WidgetStateProperty.all(Colors.grey.withAlpha(50))
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: event != null,
      body: event == null ? Center(
          child: CircularProgressIndicator(strokeWidth: 1.5)
      ) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Partie de l'image et des titres
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * .5,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: event!.imageUrl == null ?
                    AssetImage("assets/event.jpg") :
                    NetworkImage(event!.imageUrl!),
                  fit: BoxFit.cover
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(15))),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.black.withAlpha(200),
                  Colors.black.withAlpha(70)
                ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event!.title,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    event!.description,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: Colors.white
                    ),
                  )
                ],
              ),
            ),
          ),

          // Partie du contenu
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                displayingTile(
                  icon: FontAwesomeIcons.person,
                  text: "Organisateur",
                  child: Text(event!.organizer)
                ),
                displayingTile(
                  icon: FontAwesomeIcons.solidCalendarDays,
                  text: "Période",
                  child: Row(
                    children: [
                      Text(
                        "Du ${formatDate(event!.startDate)} au ${formatDate(event!.endDate)}",
                      ),
                    ],
                  ),
                ),
                displayingTile(
                  icon: FontAwesomeIcons.locationPin,
                  text: "Lieu",
                  child: Text(event!.location)
                ),
                displayingTile(
                  icon: FontAwesomeIcons.ellipsisVertical,
                  text: "Type et catégorie",
                  child: Text("${event!.type}, ${event!.category}")
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget displayingTile({
    required IconData icon,
    required String text,
    required Widget child,
  }){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                icon,
                size: 18,
                color: Colors.black
              ),
              SizedBox(width: 10),
              Text(
                text,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold
                )
              ),
            ],
          ),

          child
        ],
      ),
    );
  }

  Widget customIconTitle(IconData icon, String text) {
    return Row(
      children: [
        FaIcon(
          icon,
          size: 18,
          color: Colors.black
        ),
        SizedBox(width: 10),
        Text(
          text,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold
          )
        ),
      ],
    );
  }
}
