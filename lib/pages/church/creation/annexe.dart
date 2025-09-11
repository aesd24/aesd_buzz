import 'package:aesd/components/button.dart';
import 'package:aesd/components/dialog.dart';
import 'package:aesd/components/snack_bar.dart';
import 'package:aesd/components/field.dart';
import 'package:aesd/services/navigation.dart';
import 'package:aesd/providers/church.dart';
import 'package:aesd/screens/church/choose_church.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AnnexeChurchCreationPage extends StatefulWidget {
  const AnnexeChurchCreationPage({super.key});

  @override
  State<AnnexeChurchCreationPage> createState() =>
      _AnnexeChurchCreationPageState();
}

class _AnnexeChurchCreationPageState extends State<AnnexeChurchCreationPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  dynamic _mainChurch;

  // controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // créer l'église annexe
  _createChurch() async {
    if (_formKey.currentState!.validate()) {
      /* if (_churchImage == null) {
        showSnackBar(
            context: context,
            message: "Chargez d'abords une image",
            type: SnackBarType.warning);
        return;
      } */

      /* if (await verifyImageSize(_churchImage!)) {
        showSnackBar(
            context: context,
            message: "La taille de votre image ne doit pas dépasser 20Mo",
            type: SnackBarType.warning);
        return;
      } */

      try {
        setState(() {
          isLoading = true;
        });

        await Provider.of<Church>(context, listen: false).create(data: {
          'name': _nameController.text,
          'email': _addressController.text,
          'phone': _contactController.text,
          'location': _locationController.text,
          'description': _descriptionController.text,
          'isMain': false
        }).then((response) {
          print(response);
          if (response.statusCode == 201) {
            showSnackBar(
                context: context,
                message: "Enregistrement de l'église réussi",
                type: SnackBarType.success);

            NavigationService.pushReplacement(const ChooseChurch());
          } else if (response.statusCode == 422) {
            showSnackBar(
                context: context,
                message: "Données invalides ou déjà existante !",
                type: SnackBarType.danger);
          } else {
            showSnackBar(
                context: context,
                message: "L'enregistrement à échoué !",
                type: SnackBarType.danger);
          }
        });
      } on DioException catch (e) {
        e.printError();
        showSnackBar(
            context: context,
            message: "Erreur lors de l'envoi des données",
            type: SnackBarType.danger);
      } catch (e) {
        e.printError();
        showSnackBar(
            context: context,
            message: "Une erreur s'est produite !",
            type: SnackBarType.danger);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer une église annexe"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // nom de l'église
                /* customTextField(
                    label: "Nom de votre église",
                    placeholder: "Ex: AESD",
                    prefixIcon: const Icon(Icons.church_outlined),
                    controller: _nameController,
                    onChanged: (value) {
                      setState(() {});
                    }),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(""),
                ), */

                customButton(
                    context: context,
                    text: _mainChurch == null
                        ? "Sélectionner l'église principale"
                        : _mainChurch.name,
                    trailing: const Icon(Icons.church_outlined),
                    border: const BorderSide(width: 2, color: Colors.grey),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    highlightColor: Colors.white,
                    onPressed: () {
                      // sélection de l'église principale
                      messageBox(
                        context,
                        title: "Selectionner une église",
                        content: const Text("Selectionnez l'église principale"),
                        onOk: () => NavigationService.close(),
                      );
                    }),

                // adresse email de l'église
                customTextField(
                    label: "Adresse email",
                    placeholder: "Ex: AESD@mail.ch",
                    type: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    controller: _addressController),

                //contact de l'église
                customTextField(
                    label: "Contact de l'église",
                    placeholder: "Ex: 0122334455",
                    type: TextInputType.number,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    controller: _contactController),

                // localisation de l'église
                customTextField(
                    label: "Localisation",
                    placeholder: "Ex: Yopougon toit rouge gendarmerie",
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    controller: _locationController),

                // description de l'église
                customMultilineField(
                    label: "Description de l'église",
                    controller: _descriptionController,
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.toString().isEmpty) {
                        return "Remplissez ce champ !";
                      }
                      if (value.toString().length < 20) {
                        return "Donnez une description un peu plus concrète";
                      }
                      return null;
                    }),

                // bouton de validation
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: customButton(
                      context: context,
                      text: "Soumettre",
                      onPressed: () => _createChurch()),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
