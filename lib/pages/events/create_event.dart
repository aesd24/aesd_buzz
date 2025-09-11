import 'dart:io';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/image_container.dart';
import 'package:aesd/functions/camera_functions.dart';
import 'package:aesd/models/event.dart';
import 'package:aesd/provider/event.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class EventForm extends StatefulWidget {
  const EventForm({
    super.key,
    required this.churchId,
    this.editMode = false,
    this.event,
  });

  final int churchId;
  final bool editMode;
  final EventModel? event;

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  bool isLoading = false;
  List months = [
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre",
  ];

  bool isPublic = false;

  // affiche de l'évènement
  String? imagePath;

  // date de l'évènement
  DateTime? startDate;
  DateTime? endDate;

  // controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final typeController = TextEditingController();
  final categoryController = TextEditingController();
  final locationController = TextEditingController();
  final organizerController = TextEditingController();

  // clé de formulaire
  final _formKey = GlobalKey<FormState>();

  // fonction d'initialisation
  Future<void> init() async {
    if (widget.editMode) {
      var event = widget.event!;
      titleController.text = event.title;
      descriptionController.text = event.description;
      typeController.text = event.type;
      categoryController.text = event.category;
      locationController.text = event.location;
      organizerController.text = event.organizer;
      startDate = event.startDate;
      endDate = event.endDate;
      isPublic = event.isPublic;
      imagePath = event.imageUrl;
    }
  }

  @override
  initState() {
    super.initState();
    init();
  }

  // fonction pour la gestion des requête
  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      MessageService.showWarningMessage(
        "Veuillez renseigner correctement les champs",
      );
      return;
    }

    if (!widget.editMode && imagePath == null) {
      MessageService.showWarningMessage(
        "Veuillez ajouter l'affiche de l'événement",
      );
      return;
    }

    if (startDate == null || endDate == null) {
      MessageService.showWarningMessage(
        "Veuillez renseigner correctement les dates",
      );
      return;
    }

    widget.editMode ? await updateEvent() : await createEvent();
  }

  Future<void> updateEvent() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Event>(context, listen: false)
          .updateEvent({
            'is_public': isPublic,
            'title': titleController.text,
            'startDate': startDate,
            'endDate': endDate,
            'location': locationController.text,
            'type': typeController.text,
            'category': categoryController.text,
            'organizer': organizerController.text,
            'description': descriptionController.text,
            'churchId': widget.churchId,
            'file': imagePath == widget.event!.imageUrl ? null : imagePath,
          }, id: widget.event!.id)
          .then((value) async {
            await Provider.of<Event>(
              context,
              listen: false,
            ).getEvents(churchId: widget.churchId);

            MessageService.showSuccessMessage("Modification éffectué");
          });
    } on PathNotFoundException {
      MessageService.showErrorMessage(
        "Impossible de recupérer l'image. Sélectionné encore !",
      );
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. vérifiez votre connexion internet",
      );
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendue est survenue !");
      e.printError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> createEvent() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Event>(context, listen: false)
          .createEvent({
            'is_public': isPublic,
            'title': titleController.text,
            'startDate': startDate,
            'endDate': endDate,
            'location': locationController.text,
            'type': typeController.text,
            'category': categoryController.text,
            'organizer': organizerController.text,
            'description': descriptionController.text,
            'churchId': widget.churchId,
            'file': imagePath,
          })
          .then((value) {
            MessageService.showSuccessMessage("Evenement créé");
          });
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. vérifiez votre connexion internet",
      );
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu est survenue");
      e.printError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            !widget.editMode ? "Créez une évènement" : "Modification",
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                isPublic
                                    ? "L'évènement sera tout publique"
                                    : "L'évènement sera interne à l'église",
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            Switch(
                              value: isPublic,
                              onChanged: (value) {
                                setState(() {
                                  isPublic = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      // partie de l'affiche
                      if (!widget.editMode)
                        imagePath == null
                            ? GestureDetector(
                              onTap: () async {
                                // selectionner une photo depuis la galérie
                                File? file = await pickImage();
                                if (file != null) {
                                  imagePath = file.path;
                                  setState(() {});
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    width: 1.5,
                                    color: Colors.green,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.photo_size_select_actual_rounded,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 15),
                                    Text("Ajouter l'affiche de l'évènement"),
                                  ],
                                ),
                              ),
                            )
                            : rectanglePictureContainer(
                              label: "Ajoutez une image",
                              image: File(imagePath!),
                              onPressed: () async {
                                File? pickedFile = await pickImage(
                                  camera: true,
                                );
                                if (pickedFile != null) {
                                  setState(() {
                                    imagePath = pickedFile.path;
                                  });
                                }
                              },
                            ),

                      // en cas d'affichage de l'image reçu du serveur
                      if (widget.editMode)
                        Container(
                          width: double.infinity,
                          height: size.height * .3,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            image:
                                widget.event!.imageUrl != null
                                    ? DecorationImage(
                                      image: NetworkImage(
                                        widget.event!.imageUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                            color: Colors.grey,
                          ),
                        ),

                      // formulaire de création de l'évènement
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // titre de l'évènement
                            CustomFormTextField(
                              label: "Titre de l'évènement",
                              controller: titleController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Remplissez d'abords le champs !";
                                }
                                return null;
                              },
                              prefix: const Icon(Icons.event_note),
                            ),

                            // période de l'évènement
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomDateTimeField(
                                      label: "Date de debut",
                                      defaultValue: startDate,
                                      validate: true,
                                      onChanged: (value) {
                                        setState(() {
                                          startDate = value;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 7),
                                  Expanded(
                                    child: CustomDateTimeField(
                                      label: "Date de fin",
                                      defaultValue: endDate,
                                      validate: true,
                                      onChanged: (value) {
                                        setState(() {
                                          endDate = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            CustomFormTextField(
                              label: "Lieu de l'évènement",
                              controller: locationController,
                              validate: true,
                              prefix: const Icon(Icons.location_pin),
                            ),

                            CustomFormTextField(
                              label: "Type",
                              controller: typeController,
                              validate: true,
                            ),

                            CustomFormTextField(
                              label: "Catégorie",
                              controller: categoryController,
                              validate: true,
                            ),

                            CustomFormTextField(
                              label: "Organisateur",
                              controller: organizerController,
                              validate: true,
                              prefix: Icon(
                                FontAwesomeIcons.solidUser,
                                size: 20,
                              ),
                            ),

                            // description de l'évènement
                            MultilineField(
                              label: "Description de l'évènement",
                              controller: descriptionController,
                              validate: true,
                              validator: (value) {
                                if (value!.length < 30) {
                                  return "Donnez une description un peu plus détaillée";
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomElevatedButton(
                text: "Soumettre",
                icon: cusFaIcon(
                  FontAwesomeIcons.paperPlane,
                  color: Colors.white,
                ),
                onPressed: () => handleSubmit(),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
