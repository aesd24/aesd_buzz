import 'dart:io';

import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/loader.dart';
import 'package:aesd/components/modal.dart';
import 'package:aesd/functions/camera_functions.dart';
import 'package:aesd/functions/file_functions.dart';
import 'package:aesd/models/ceremony.dart';
import 'package:aesd/provider/ceremonies.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CeremonyForm extends StatefulWidget {
  const CeremonyForm({
    super.key,
    required this.churchId,
    this.ceremony,
    this.editMode = false,
  });

  final int churchId;
  final CeremonyModel? ceremony;
  final bool editMode;

  @override
  State<CeremonyForm> createState() => _CeremonyFormState();
}

class _CeremonyFormState extends State<CeremonyForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // data
  File? movie;
  DateTime? date;

  // controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future init() async {
    if (widget.editMode) {
      _titleController.text = widget.ceremony!.title;
      _descriptionController.text = widget.ceremony!.description;
      date = widget.ceremony!.date;
    }
  }

  @override
  initState() {
    super.initState();
    init();
  }

  // functions
  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      MessageService.showWarningMessage(
        "Veuillez renseigner correctement les champs",
      );
      return;
    }

    // vérifications
    if (date == null) {
      MessageService.showWarningMessage(
        "Veuillez renseignez une date pour l'évènement",
      );
      return;
    }
    if (!widget.editMode) {
      if (movie == null) {
        MessageService.showWarningMessage(
          "Veuillez ajouter le film de la cérémonie",
        );
        return;
      }
    }

    showModal(
      context: context,
      dialog: CustomAlertDialog(
        title: "Avertissement",
        content:
            "Le chargement pourrait prendre du temps à cause de la taille du fichier.",
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(Colors.grey),
            ),
            child: Text("Annuler"),
          ),
          TextButton.icon(
            onPressed: () async {
              Get.back();
              !widget.editMode
                  ? await createCeremony()
                  : await updateCeremony();
            },
            icon: FaIcon(FontAwesomeIcons.check),
            iconAlignment: IconAlignment.end,
            label: Text("Ok"),
          ),
        ],
      ),
    );
  }

  Future<void> updateCeremony() async {
    // Effectuer la création
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Ceremonies>(context, listen: false)
          .update({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'date': date!,
            'movie': movie?.path,
            "church_id": widget.churchId,
          }, id: widget.ceremony!.id)
          .then((value) async {
            await Provider.of<Ceremonies>(
              context,
              listen: false,
            ).all(churchId: widget.churchId);
            MessageService.showSuccessMessage(value['message']);
          });
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException catch (e) {
      e.printError();
      MessageService.showErrorMessage(
        "Erreur réseau. Vérifiez votre connexion internet et rééssayez...",
      );
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendue est survenue");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> createCeremony() async {
    // Effectuer la création
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Ceremonies>(context, listen: false)
          .create({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'date': date!,
            'movie': movie!.path,
            "church_id": widget.churchId,
          })
          .then((value) {
            MessageService.showSuccessMessage("Cérémonie créé avec succès");
            Provider.of<Ceremonies>(
              context,
              listen: false,
            ).all(churchId: widget.churchId);
          });
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException catch (e) {
      e.printError();
      MessageService.showErrorMessage(
        "Erreur réseau. Vérifiez votre connexion internet et rééssayez...",
      );
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendue est survenue");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomFileLoader(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(title: Text("Création de cérémonie")),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CustomFormTextField(
                          prefix: cusIcon(FontAwesomeIcons.church),
                          controller: _titleController,
                          label: "Titre de la cérémonie",
                          validate: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Ce champs est obligatoire";
                            }
                            return null;
                          },
                        ),

                        CustomDateTimeField(
                          label: "Date de la cérémonie",
                          lastDate: DateTime.now(),
                          defaultValue: date,
                          onChanged: (value) => setState(() => date = value),
                        ),

                        MultilineField(
                          label: "Descrivez la cérémonie...",
                          controller: _descriptionController,
                          validate: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Ce champs est obligatoire";
                            }
                            return null;
                          },
                        ),

                        InkWell(
                          onTap: () async {
                            File? file = await pickVideo();
                            if (file != null) {
                              setState(() => movie = file);
                            } else {
                              MessageService.showErrorMessage(
                                "Echec du chargement de la vidéo",
                              );
                            }
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    movie == null ? Colors.grey : Colors.green,
                              ),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  movie == null
                                      ? Icons.movie
                                      : Icons.check_circle,
                                  size: 80,
                                  color:
                                      movie == null
                                          ? Colors.grey
                                          : Colors.green,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  movie == null
                                      ? "Chargez le film de la cérémonie ${widget.editMode ? "(optionnel)" : ""}"
                                      : "Vidéo chargé",
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Ajoutez une vidéo de moins de 300 Mo",
                            style: Theme.of(context).textTheme.labelMedium!
                                .copyWith(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CustomElevatedButton(
                  text: "Valider",
                  icon: cusFaIcon(FontAwesomeIcons.paperPlane),
                  onPressed: () async => await handleSubmit(),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
