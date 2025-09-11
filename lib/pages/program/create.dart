import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/services/message.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';

class CreateProgramForm extends StatefulWidget {
  const CreateProgramForm({super.key});

  @override
  State<CreateProgramForm> createState() => _CreateProgramFormState();
}

class _CreateProgramFormState extends State<CreateProgramForm> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();

  // variables
  dynamic day;
  List weekDays = [
    "lundi",
    "mardi",
    "mercredi",
    "jeudi",
    "vendredi",
    "samedi",
    "dimanche",
  ];

  DateTime? programDate;
  DateTime? startTime;
  DateTime? endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un programme")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomDropdownButton(
                  label: "Choisissez le jour du programme",
                  items: List.generate(weekDays.length, (index) {
                    return DropdownMenuItem(
                      value: (index + 1).toString(),
                      child: Text(weekDays[index]),
                    );
                  }),
                  value: day,
                  onChanged: (value) {
                    day = value;
                  },
                ),
                CustomFormTextField(
                  label: "Titre du programme",
                  controller: _titleController,
                  suffix: const Icon(Icons.title),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Renseignez le titre du programme";
                    }
                    if (value.length < 5) {
                      return "Le titre doit contenir au moins 5 caractères";
                    }
                    return null;
                  },
                ),
                CustomFormTextField(
                  label: "Lieu de déroulement",
                  controller: _placeController,
                  suffix: const Icon(Icons.location_pin),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Renseignez le titre du programme";
                    }
                    return null;
                  },
                ),
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
                const SizedBox(height: 10),
                CustomElevatedButton(
                  text: "Valider",
                  onPressed: () {
                    if (day == null) {
                      MessageService.showWarningMessage(
                        "Choisissez le jour du programme",
                      );
                      return;
                    }

                    if (startTime == null) {
                      MessageService.showWarningMessage(
                        "Renseignez l'heure de début",
                      );
                      return;
                    }

                    if (endTime == null) {
                      MessageService.showWarningMessage(
                        "Renseignez l'heure de fin",
                      );
                      return;
                    }

                    if (_formKey.currentState!.validate()) {
                      //print("Création du programme");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
