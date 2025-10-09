import 'dart:io';

import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/bottom_sheets.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/provider/program.dart';
import 'package:aesd/services/message.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CreateProgramForm extends StatefulWidget {
  const CreateProgramForm({super.key, required this.churchId});

  final int churchId;

  @override
  State<CreateProgramForm> createState() => _CreateProgramFormState();
}

class _CreateProgramFormState extends State<CreateProgramForm> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  // controllers
  final _titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // variables
  String day = "";
  List weekDays = [
    "lundi",
    "mardi",
    "mercredi",
    "jeudi",
    "vendredi",
    "samedi",
    "dimanche",
  ];

  DateTime? startTime;
  DateTime? endTime;
  File? image;

  Future _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      await createProgram();
    }
  }

  Future createProgram() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final data = {
        "title": _titleController.text,
        "description": descriptionController.text,
        "day": day,
        "start_time": getTimePart(startTime!),
        "end_time": getTimePart(endTime!),
        "church_id": widget.churchId,
        "file": image,
      };
      await Provider.of<ProgramProvider>(
        context,
        listen: false,
      ).createProgram(data).then((value) {
        MessageService.showSuccessMessage("Programme ajouté avec succès !");
        Get.back();
      });
    } catch (e) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .7,
      decoration: BoxDecoration(
        color: notifire.getbgcolor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: customBackButton(icon: FontAwesomeIcons.xmark),
          title: Text(
            "Créer un programme",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child:
                  _isLoading
                      ? CircularProgressIndicator(strokeWidth: 1.5)
                      : CustomTextButton(
                        label: "Valider",
                        onPressed: () async => await _handleSubmit(),
                      ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      pickModeSelectionBottomSheet(
                        context: context,
                        setter:
                            (pic) => setState(() {
                              image = pic;
                            }),
                      );
                    },
                    child: Builder(
                      builder: (context) {
                        Color color =
                            image != null ? Colors.green : notifire.getMaingey;
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: color.withAlpha(75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: cusFaIcon(
                                  FontAwesomeIcons.image,
                                  size: 40,
                                ),
                              ),
                              Text(
                                image != null
                                    ? "Image ajouté avec succès"
                                    : "Ajouter une image (facultatif)",
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  CustomDropdownButton(
                    label: "Choisissez le jour du programme",
                    items: List.generate(weekDays.length, (index) {
                      return DropdownMenuItem(
                        value: weekDays[index],
                        child: Text(weekDays[index]),
                      );
                    }),
                    validate: true,
                    value: day,
                    onChanged: (value) {
                      day = value ?? "";
                    },
                  ),
                  CustomFormTextField(
                    label: "Titre du programme",
                    controller: _titleController,
                    validate: true,
                    validator: (value) {
                      if (value!.length < 5) {
                        return "Le titre doit contenir au moins 5 caractères";
                      }
                      return null;
                    },
                  ),

                  // heures de début et de fin
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomDateTimeField(
                            label: "Heure de debut",
                            defaultValue: startTime,
                            mode: DateTimeFieldPickerMode.time,
                            validate: true,
                            validator: (value) {
                              if (startTime == null) {
                                return "Renseignez l'heure de début";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                startTime = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: CustomDateTimeField(
                            label: "Heure de fin",
                            defaultValue: endTime,
                            mode: DateTimeFieldPickerMode.time,
                            validate: true,
                            validator: (value) {
                              if (endTime == null) {
                                return "Renseignez l'heure de fin";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                endTime = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  MultilineField(
                    label: "Description du programme",
                    validate: true,
                    controller: descriptionController,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
