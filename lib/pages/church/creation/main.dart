import 'dart:io';
import 'package:aesd/components/bottom_sheets.dart';
import 'package:aesd/components/button.dart';
import 'package:aesd/components/drop_down.dart';
import 'package:aesd/components/picture_containers.dart';
import 'package:aesd/components/snack_bar.dart';
import 'package:aesd/components/field.dart';
import 'package:aesd/constants/dictionnary.dart';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/providers/church.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class MainChurchCreationPage extends StatefulWidget {
  MainChurchCreationPage({super.key, this.editMode = false, this.churchId});

  bool editMode;
  int? churchId;

  @override
  State<MainChurchCreationPage> createState() => _MainChurchCreationPageState();
}

class _MainChurchCreationPageState extends State<MainChurchCreationPage> {
  ChurchModel? church;
  bool isLoading = false;

  // clé de formulaire
  final _formKey = GlobalKey<FormState>();

  // form controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // attestation d'existance
  File? _attestationFile;
  getAttentation() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      _attestationFile = File(result.files.single.path!);
    }
    setState(() {});
  }

  // valeur du type d'église
  String? churchType;

  // photo de l'église
  File? _churchImage;
  setChurchImage(dynamic image) async {
    _churchImage = await image;
    setState(() {});
  }

  // fonction de création d'une nouvelle église
  createChurch() async {
    if (_formKey.currentState!.validate()) {
      if (_churchImage == null) {
        showSnackBar(
            context: context,
            message: "Chargez d'abords une image",
            type: SnackBarType.warning);
        return;
      }

      if (_attestationFile == null) {
        showSnackBar(
            context: context,
            message: "Chargez l'attestation d'existence de votre église",
            type: SnackBarType.warning);
        return;
      }

      try {
        setState(() {
          isLoading = true;
        });

        print(_attestationFile!.path);

        await Provider.of<Church>(context, listen: false).create(data: {
          'name': _nameController.text,
          'email': _addressController.text,
          'phone': _contactController.text,
          'location': _locationController.text,
          'description': _descriptionController.text,
          'isMain': 1,
          'attestation_file': _attestationFile,
          'churchType': churchType,
          'image': _churchImage
        }).then((response) {
          print(response);
          showSnackBar(
              context: context,
              message: "Enregistrement de l'église réussi",
              type: SnackBarType.success);

          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      } on HttpException catch (e) {
        e.printError();
        showSnackBar(
            context: context, message: e.message, type: SnackBarType.danger);
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
    } else {
      showSnackBar(
          context: context,
          message: "Remplissez correctement tout les champs",
          type: SnackBarType.warning);
    }
  }

  // fonction de modification de l'église
  updateChurch() async {
    if (_formKey.currentState!.validate()) {
      if (_churchImage == null) {
        showSnackBar(
          context: context,
          message: "Chargez d'abords une image",
          type: SnackBarType.warning
        );
        return;
      }

      try {
        setState(() {
          isLoading = true;
        });

        await Provider.of<Church>(context, listen: false).update(church!.id, data: {
          'name': _nameController.text,
          'email': _addressController.text,
          'phone': _contactController.text,
          'location': _locationController.text,
          'description': _descriptionController.text,
          'churchType': churchType,
          'image': _churchImage
        }).then((response) async {
          print(response);
          showSnackBar(
            context: context,
            message: "Modification de l'église réussi",
            type: SnackBarType.success
          );
          await Provider.of<Church>(context, listen: false).getUserChurches();

          setState(() {});

          //Navigator.of(context).popUntil((route) => route.isFirst);
        });
      } on HttpException catch (e) {
        e.printError();
        showSnackBar(
            context: context, message: e.message, type: SnackBarType.danger);
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
    } else {
      showSnackBar(
          context: context,
          message: "Remplissez correctement tout les champs",
          type: SnackBarType.warning);
    }
  }

  init() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (widget.editMode == true) {
        // obtention de l'église du serviteur
        await Provider.of<Church>(context, listen: false).fetchChurch(widget.churchId!).then((value) {
          church = ChurchModel.fromJson(value['eglise']);
        });

        //mise en place des données dans les champs
        _nameController.text = church!.name;
        _addressController.text = church!.email;
        _contactController.text = church!.phone;
        _descriptionController.text = church!.description;
        _locationController.text = church!.address;

        for (var t in churchTypes) {
          if (church!.type == t.code) {
            churchType = t.code;
          }
        }
        print(church!.type);
      }
    } catch (e) {
      e.printError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool update = widget.editMode;
    return LoadingOverlay(
      isLoading: isLoading,
      color: Colors.black.withAlpha(70),
      child: Scaffold(
        appBar: AppBar(
            title: Text(update
                ? 'Modifier mon église'
                : 'Créer une église')),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    pickModeSelectionBottomSheet(
                                        context: context,
                                        setter: setChurchImage);
                                  },
                                  child: !widget.editMode ? customRoundedAvatar(
                                    image: _churchImage,
                                    overlayText: "Cliquez pour ajoutez une photo"
                                  ):
                                  CircleAvatar(
                                    radius: 85,
                                    child: CircleAvatar(
                                      radius: 70,
                                      backgroundImage: church?.logo != null ?
                                      NetworkImage(church!.logo!) : null,
                                    ),
                                  )
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    _nameController.text == ""
                                        ? "Renseignez le nom de l'église"
                                        : _nameController.text,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        // bouton pour charger l'attestion d'existence de l'église
                        if (! widget.editMode) ...[GestureDetector(
                          onTap: () async => await getAttentation(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: _attestationFile == null
                                      ? Colors.grey
                                      : Colors.green,
                                  width: 1),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Row(
                              children: [
                                _attestationFile == null
                                    ? const FaIcon(
                                        FontAwesomeIcons.fileCirclePlus)
                                    : const FaIcon(
                                        FontAwesomeIcons.circleCheck,
                                        color: Colors.green,
                                      ),
                                const SizedBox(width: 20),
                                Flexible(
                                    child: Text(
                                  _attestationFile == null
                                      ? "Chargez l'attestation d'existance"
                                      : "Attestation chargé !",
                                  style: _attestationFile != null
                                      ? const TextStyle(color: Colors.green)
                                      : null,
                                  overflow: TextOverflow.clip,
                                ))
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 20),
                          child: Text(
                            "Chargez un fichier au format PDF de moins de 2 Go",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.black87),
                          ),
                        )],

                        // nom de l'église
                        customTextField(
                            label: "Nom de votre église",
                            placeholder: "Ex: AESD",
                            prefixIcon: const Icon(Icons.church_outlined),
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.toString().isEmpty) {
                                return "Ce champs est requis";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {});
                            }),

                        // adresse email de l'église
                        customTextField(
                            label: "Adresse email",
                            placeholder: "Ex: AESD@mail.ch",
                            type: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: (value) {
                              if (value == null || value.toString().isEmpty) {
                                return "Ce champs est requis";
                              }
                              if (!RegExp(
                                      "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]{2,}?\\.[a-zA-Z]{2,}\$")
                                  .hasMatch(value)) {
                                if (!RegExp("^[a-zA-Z0-9._%-]{5,}")
                                    .hasMatch(value)) {
                                  return "Entrez au moins 5 caractères avant le '@'";
                                }
                                if (!RegExp("^[.]*.[a-zA-Z0-9]{2,}\$")
                                    .hasMatch(value)) {
                                  return "Nom de domaine invalide !";
                                }
                                return "Adresse email invalide !";
                              }
                              return null;
                            },
                            controller: _addressController),

                        //contact de l'église
                        customTextField(
                            label: "Contact de l'église",
                            placeholder: "Ex: 0122334455",
                            type: TextInputType.number,
                            prefixIcon: const Icon(Icons.phone_outlined),
                            validator: (value) {
                              if (value == null || value.toString().isEmpty) {
                                return "Ce champs est requis";
                              }
                              if (!RegExp('^[0-9]{10}\$').hasMatch(value)) {
                                return "Entrez un numéro à 10 chiffres";
                              }

                              if (!RegExp("^(01|07|05)").hasMatch(value)) {
                                return "Le numéro doit commencer par 01, 05 ou 07";
                              }
                              return null;
                            },
                            controller: _contactController),

                        // type d'église
                        customDropDownField(
                            prefixIcon: const Icon(Icons.wb_sunny_outlined),
                            label: "Type d'église",
                            placeholder: "Quel est le type de votre église ?",
                            value: churchType,
                            items: List.generate(churchTypes.length, (index) {
                              var current = churchTypes[index];
                              return DropdownMenuItem(
                                  value: current.code,
                                  child: Text(current.name));
                            }),
                            onChange: (value) {
                              churchType = value;
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Veuillez choisir un type d'église";
                              }
                              return null;
                            }),

                        // localisation de l'église
                        customTextField(
                            label: "Localisation",
                            placeholder: "Ex: Yopougon toit rouge gendarmerie",
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            validator: (value) {
                              if (value == null || value.toString().isEmpty) {
                                return "Ce champs est requis";
                              }
                              return null;
                            },
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
                                return "Donnez une description un peu plus concise";
                              }
                              return null;
                            }),
                      ],
                    ),
                  ),
                ),
              ),
              // bouton de validation
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: customButton(
                    context: context,
                    text: "Soumettre",
                    onPressed: () => widget.editMode ? updateChurch() : createChurch()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
