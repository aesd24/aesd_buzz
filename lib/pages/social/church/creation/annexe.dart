import 'dart:io';

import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class AnnexeChurchForm extends StatefulWidget {
  const AnnexeChurchForm({super.key});

  @override
  State<AnnexeChurchForm> createState() => _AnnexeChurchFormState();
}

class _AnnexeChurchFormState extends State<AnnexeChurchForm> {
  bool isLoading = false;

  // clé de formulaire
  final _formKey = GlobalKey<FormState>();

  // form controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // fonction de création d'une nouvelle église
  Future<void> createChurch() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true;
        });

        await Provider.of<Church>(context, listen: false)
            .create(
              data: {
                'name': _nameController.text,
                'email': _addressController.text,
                'phone': _contactController.text,
                'location': _locationController.text,
                'description': _descriptionController.text,
                'isMain': 1,
              },
            )
            .then((response) {
              MessageService.showSuccessMessage("Eglise enregistrée !");
              Navigator.of(context).popUntil((route) => route.isFirst);
            });
      } on HttpException catch (e) {
        e.printError();
        MessageService.showErrorMessage(e.message);
      } on DioException catch (e) {
        e.printError();
        MessageService.showErrorMessage(
          "Erreur réseaux. Vérifiez votre internet",
        );
      } catch (e) {
        e.printError();
        MessageService.showErrorMessage("Une erreur inattendue s'est produite");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      MessageService.showWarningMessage(
        "Remplissez correctement tout les champs",
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      color: Colors.black.withAlpha(70),
      child: Scaffold(
        appBar: AppBar(
          leading: customBackButton(),
          title: Text('Créer une église annexe'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // nom de l'église
                        CustomFormTextField(
                          label: "Nom de votre église",
                          prefix: cusIcon(Icons.church_outlined),
                          controller: _nameController,
                        ),

                        // adresse email de l'église
                        CustomFormTextField(
                          label: "Adresse email",
                          type: TextInputType.emailAddress,
                          prefix: cusIcon(FontAwesomeIcons.at),
                          controller: _addressController,
                        ),

                        //contact de l'église
                        CustomFormTextField(
                          label: "Contact de l'église",
                          type: TextInputType.number,
                          prefix: cusIcon(Icons.phone_outlined),
                          validate: true,
                          validator: (value) {
                            if (!RegExp('^[0-9]{10}\$').hasMatch(value!)) {
                              return "Entrez un numéro à 10 chiffres";
                            }

                            if (!RegExp("^(01|07|05)").hasMatch(value)) {
                              return "Le numéro doit commencer par 01, 05 ou 07";
                            }
                            return null;
                          },
                          controller: _contactController,
                        ),

                        // localisation de l'église
                        CustomFormTextField(
                          label: "Localisation",
                          prefix: cusIcon(Icons.location_on_outlined),
                          validate: true,
                          controller: _locationController,
                        ),

                        // description de l'église
                        MultilineField(
                          label: "Description de l'église",
                          controller: _descriptionController,
                          validate: true,
                          validator: (value) {
                            if (value!.toString().length < 20) {
                              return "Donnez une description un peu plus concise";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // bouton de validation
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: CustomElevatedButton(
                  text: "Soumettre",
                  onPressed: () => createChurch(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
