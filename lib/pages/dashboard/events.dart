import 'dart:io';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/provider/event.dart';
import 'package:aesd/pages/events/create_event.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class ChurchEvents extends StatefulWidget {
  const ChurchEvents({super.key, required this.churchId});

  final int churchId;

  @override
  State<ChurchEvents> createState() => _ChurchEventsState();
}

class _ChurchEventsState extends State<ChurchEvents> {
  bool _isLoading = false;

  Future<void> init() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Event>(
        context,
        listen: false,
      ).getEvents(churchId: widget.churchId);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur de connexion. Vérifiez votre connexion internet",
      );
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendue est survenue !");
      e.printError();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future deleteEvent(int id) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Event>(context, listen: false).delete(id).then((value) {
        MessageService.showSuccessMessage("Element supprimé avec succès !");
      });
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur de connexion. Vérifiez votre connexion internet",
      );
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendue est survenue !");
      e.printError();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: FaIcon(FontAwesomeIcons.xmark, size: 20),
          ),
          centerTitle: true,
          title: Text('Evènements', style: TextStyle(fontSize: 20)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              CustomElevatedButton(
                text: "Ajouter un évènement",
                icon: FaIcon(FontAwesomeIcons.film, color: Colors.white),
                onPressed:
                    () => Get.to(
                      EventForm(churchId: widget.churchId),
                    ),
              ),
              CustomFormTextField(
                prefix: Icon(Icons.search),
                label: "Rechercher",
              ),

              Consumer<Event>(
                builder: (context, eventProvider, child) {
                  if (eventProvider.events.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          "Aucun évènement disponible",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: eventProvider.events.length,
                        itemBuilder: (context, index) {
                          var current = eventProvider.events[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: current.buildWidget(
                              context,
                              onDelete: deleteEvent,
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
