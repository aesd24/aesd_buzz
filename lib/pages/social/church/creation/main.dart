import 'dart:io';
import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/bottom_sheets.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/image_container.dart';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class MainChurchCreationPage extends StatefulWidget {
  const MainChurchCreationPage({
    super.key,
    this.editMode = false,
    this.churchId,
  });

  final bool editMode;
  final int? churchId;

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
  Future<void> getAttestation() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      _attestationFile = File(result.files.single.path!);
    }
    setState(() {});
  }

  // valeur du type d'église
  String? churchType;

  // photo de l'église
  File? _churchImage;
  Future<void> setChurchImage(dynamic image) async {
    _churchImage = await image;
    setState(() {});
  }

  // fonction de création d'une nouvelle église
  Future<void> createChurch() async {
    if (_formKey.currentState!.validate()) {
      if (_churchImage == null) {
        return MessageService.showWarningMessage("Chargez d'abords une image");
      }

      if (_attestationFile == null) {
        return MessageService.showWarningMessage(
          "Chargez d'abords l'attestation d'existance",
        );
      }

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
                'attestation_file': _attestationFile,
                'churchType': churchType,
                'image': _churchImage,
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

  // fonction de modification de l'église
  Future<void> updateChurch() async {
    if (_formKey.currentState!.validate()) {
      if (_churchImage == null) {
        return MessageService.showWarningMessage("Chargez d'abords une image");
      }

      try {
        setState(() {
          isLoading = true;
        });

        await Provider.of<Church>(context, listen: false)
            .update(
              church!.id,
              data: {
                'name': _nameController.text,
                'email': _addressController.text,
                'phone': _contactController.text,
                'location': _locationController.text,
                'description': _descriptionController.text,
                'churchType': churchType,
                'image': _churchImage,
              },
            )
            .then((response) async {
              MessageService.showSuccessMessage(
                "Modification de l'église réussi",
              );
              await Provider.of<Church>(
                context,
                listen: false,
              ).getUserChurches();
            });
      } on HttpException catch (e) {
        e.printError();
        MessageService.showErrorMessage(e.message);
      } on DioException catch (e) {
        e.printError();
        MessageService.showErrorMessage("Erreur lors de l'envoi des données");
      } catch (e) {
        e.printError();
        MessageService.showErrorMessage("Une erreur s'est produite !");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      MessageService.showErrorMessage(
        "Remplissez correctement tout les champs",
      );
    }
  }

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (widget.editMode == true) {
        // obtention de l'église du serviteur
        await Provider.of<Church>(
          context,
          listen: false,
        ).fetchChurch(widget.churchId!).then((value) {
          church = Provider.of<Church>(context, listen: false).selectedChurch;
        });

        //mise en place des données dans les champs
        _nameController.text = church!.name;
        _addressController.text = church!.email;
        _contactController.text = church!.phone;
        _descriptionController.text = church!.description;
        _locationController.text = church!.address;

        for (var t in Dictionnary.churchTypes) {
          if (church!.type == t.code) {
            churchType = t.code;
          }
        }
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
          leading: customBackButton(),
          title: Text(update ? 'Modifier mon église' : 'Créer une église'),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    pickModeSelectionBottomSheet(
                                      context: context,
                                      setter: setChurchImage,
                                    );
                                  },
                                  child:
                                      !widget.editMode
                                          ? idPictureContainer(
                                            image: _churchImage,
                                            onPressed: () {
                                              try {
                                                pickModeSelectionBottomSheet(
                                                  context: context,
                                                  setter: setChurchImage,
                                                );
                                              } catch (e) {
                                                e.printError();
                                                MessageService.showErrorMessage(
                                                  e.toString(),
                                                );
                                              }
                                            },
                                          )
                                          : CircleAvatar(
                                            radius: 85,
                                            backgroundColor:
                                                notifire.getMaingey,
                                            backgroundImage:
                                                church?.logo != null
                                                    ? FastCachedImageProvider(
                                                      church!.logo!,
                                                    )
                                                    : null,
                                          ),
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
                                ),
                              ],
                            ),
                          ),
                        ),

                        // bouton pour charger l'attestion d'existence de l'église
                        if (!widget.editMode) ...[
                          GestureDetector(
                            onTap: () async => await getAttestation(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 15,
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color:
                                      _attestationFile == null
                                          ? Colors.grey
                                          : Colors.green,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Row(
                                children: [
                                  _attestationFile == null
                                      ? const FaIcon(
                                        FontAwesomeIcons.fileCirclePlus,
                                      )
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
                                      style:
                                          _attestationFile != null
                                              ? const TextStyle(
                                                color: Colors.green,
                                              )
                                              : null,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 20),
                            child: Text(
                              "Chargez un fichier au format PDF de moins de 2 Go",
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(color: Colors.black87),
                            ),
                          ),
                        ],

                        // nom de l'église
                        CustomFormTextField(
                          label: "Nom de votre église",
                          prefix: cusIcon(Icons.church_outlined),
                          controller: _nameController,
                          validate: true,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),

                        // adresse email de l'église
                        CustomFormTextField(
                          label: "Adresse email",
                          type: TextInputType.emailAddress,
                          prefix: cusIcon(FontAwesomeIcons.at),
                          validator: (value) {
                            if (!RegExp(
                              "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]{2,}?\\.[a-zA-Z]{2,}\$",
                            ).hasMatch(value!)) {
                              if (!RegExp(
                                "^[a-zA-Z0-9._%-]{5,}",
                              ).hasMatch(value)) {
                                return "Entrez au moins 5 caractères avant le '@'";
                              }
                              if (!RegExp(
                                "^[.]*.[a-zA-Z0-9]{2,}\$",
                              ).hasMatch(value)) {
                                return "Nom de domaine invalide !";
                              }
                              return "Adresse email invalide !";
                            }
                            return null;
                          },
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

                        // type d'église
                        CustomDropdownButton(
                          prefix: cusIcon(Icons.wb_sunny_outlined),
                          label: "Type d'église",
                          value: churchType ?? '',
                          items: List.generate(Dictionnary.churchTypes.length, (
                            index,
                          ) {
                            var current = Dictionnary.churchTypes[index];
                            return DropdownMenuItem(
                              value: current.code,
                              child: Text(current.name),
                            );
                          }),
                          onChanged: (value) {
                            churchType = value;
                          },
                          validate: true,
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
                  onPressed:
                      () => widget.editMode ? updateChurch() : createChurch(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
