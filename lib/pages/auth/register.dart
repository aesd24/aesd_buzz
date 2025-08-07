import 'dart:async';
import 'dart:io';

import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/containers.dart';
import 'package:aesd/components/divider.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/image_container.dart';
import 'package:aesd/functions/camera_functions.dart';
import 'package:aesd/functions/file_functions.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/schemas/user.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.loadingCallBack, this.reInitCallBack});

  final void Function()? loadingCallBack;
  final void Function()? reInitCallBack;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  int _pageIndex = 0;

  // controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _managerController = TextEditingController();

  UserCreate _schema = UserCreate();

  bool terms = false;
  String _call = Dictionnary.pastor.code;
  String accountType = Dictionnary.faithFul.code;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      MessageService.showErrorMessage(
        "Remplissez correctement le formulaire s'il vous plait !",
      );
    } else {
      if (!terms) {
        MessageService.showWarningMessage(
          "Veuillez accepter les termes et conditions d'utilisation pour continuer",
        );
      } else {
        FocusScope.of(context).unfocus();
        if (_pageIndex == 0) {
          _schema = UserCreate(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            adress: _addressController.text,
            password: _passwordController.text,
            passwordConfirmation: _passwordConfirmController.text,
            accountType: accountType,
            call: _call,
            description: _descriptionController.text,
            manager: _managerController.text,
            terms: terms,
          );
        }

        if (accountType != Dictionnary.servant.code) {
          await _register();
        } else {
          if (_pageIndex != 1) {
            setState(() {
              _pageIndex++;
            });
          } else {
            if (_schema.idPicture == null) {
              MessageService.showWarningMessage(
                "Veuillez ajouter une photo d'identité",
              );
            } else if (_schema.idCardRecto == null) {
              MessageService.showWarningMessage(
                "Veuillez ajouter le recto de la carte d'identité",
              );
            } else if (_schema.idCardVerso == null) {
              MessageService.showWarningMessage(
                "Veuillez ajouter le verso de la carte d'identité",
              );
            } else {
              await _register();
            }
          }
        }
      }
    }
  }

  Future<void> _register() async {
    try {
      widget.loadingCallBack!();
      Provider.of<Auth>(context, listen: false).setCreationSchema(_schema);
      await Provider.of<Auth>(context, listen: false).register().then((value) {
        if (value) {
          MessageService.showSuccessMessage(
            "Inscription reussi. Connectez-vous...",
          );
          widget.reInitCallBack!();
        }
      });
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException catch (e) {
      e.printError();
      MessageService.showErrorMessage(
        "Une erreur s'est produite, vérifiez la connexion internet et rééssayez",
      );
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur s'est produite");
    } finally {
      widget.loadingCallBack!();
    }
  }

  FutureOr<File?> _pickImage() async {
    File? pickedFile = await pickImage();
    if (pickedFile != null) {
      var result = await verifyImageSize(pickedFile);
      if (result.isGood) {
        return pickedFile;
      } else {
        throw Exception(
          "Le fichier chargé est trop lourd : ${result.length}Mo",
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return authContainer(
      title: "Inscription",
      subtitle: "Remplissez les champs pour créer votre compte",
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            [
              // formulaire pour renseigner les informations
              _registerForm(),

              // Ajouter les images dans le cas d'un compte serviteur
              _addPictures(),
            ][_pageIndex],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (accountType == Dictionnary.servant.code && _pageIndex != 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: BackButton(
                      onPressed: () {
                        setState(() {
                          _pageIndex = 0;
                        });
                      },
                      style: ButtonStyle(
                        iconColor: WidgetStatePropertyAll(
                          notifire!.geticoncolor,
                        ),
                        fixedSize: WidgetStatePropertyAll(Size(60, 60)),
                      ),
                    ),
                  ),

                Expanded(
                  child: CustomElevatedButton(
                    text: "Continuer",
                    icon: cusIcon(
                      FontAwesomeIcons.arrowRight,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      _handleRegister();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerForm() {
    return Column(
      children: [
        // types de comptes
        CustomDropdownButton(
          label: "Type de compte",
          value: accountType,
          validate: true,
          prefix: cusIcon(FontAwesomeIcons.userTie),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                accountType = value;
              });
            }
          },
          items: List.generate(Dictionnary.accountTypes.length, (index) {
            final accountType = Dictionnary.accountTypes[index];
            return DropdownMenuItem(
              value: accountType.code,
              child: Text(accountType.name),
            );
          }),
        ),

        if (accountType == Dictionnary.servant.code)
          CustomDropdownButton(
            label: "Quel est votre appel ?",
            value: _call,
            validate: true,
            prefix: cusIcon(Icons.wb_sunny),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _call = value;
                });
              }
            },
            items: List.generate(Dictionnary.servantCalls.length, (index) {
              final call = Dictionnary.servantCalls[index];
              return DropdownMenuItem(value: call.code, child: Text(call.name));
            }),
          ),

        CustomFormTextField(
          controller: _nameController,
          label: "Nom & prénoms",
          prefix: cusIcon(FontAwesomeIcons.solidUser),
          validate: true,
        ),

        EmailField(
          controller: _emailController,
          label: "Adresse e-mail",
          validate: true,
        ),

        PhoneField(controller: _phoneController, validate: true),

        CustomFormTextField(
          controller: _addressController,
          label: "Adresse",
          prefix: cusIcon(FontAwesomeIcons.locationDot),
          validate: true,
        ),

        if (accountType == Dictionnary.singer.code) ...[
          CustomFormTextField(
            controller: _managerController,
            label: "Manager",
            prefix: cusIcon(FontAwesomeIcons.userTie),
            validate: true,
          ),

          MultilineField(
            controller: _descriptionController,
            label: "Description",
          ),
        ],

        PasswordField(
          controller: _passwordController,
          validator: (value) {
            if (value.toString().length < 8) {
              return "Entrez un mot de passe d'au moins 8 caractères";
            }

            if (!RegExp("[0-9]+").hasMatch(value!)) {
              return "Le mot de passe doit contenir au moins un chiffre";
            }

            if (!RegExp("[A-Z]+").hasMatch(value)) {
              return "Le mot de passe doit contenir au moins une majuscule";
            }

            if (RegExp('[ ]+').hasMatch(value)) {
              return "Le mot de passe ne doit pas contenir d'espace";
            }
            return null;
          },
          validate: true,
        ),

        PasswordField(
          controller: _passwordConfirmController,
          label: "Confirmer le mot de passe",
          validator: (value) {
            if (value != _passwordController.text) {
              return "Les mots de passe ne correspondent pas";
            }
            return null;
          },
          validate: true,
        ),

        // termes et conditions
        CheckboxListTile(
          activeColor: Colors.green,
          checkColor: Colors.white,
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "J'ai lu et j'accepte les ",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                TextSpan(
                  text: "conditions générales d'utilisation",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(color: Colors.green),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () async {
                          Uri url = Uri.parse(
                            "https://eglisesetserviteursdedieu.com/terms-of-service",
                          );
                          launchUrl(url, mode: LaunchMode.inAppBrowserView);
                        },
                ),
                TextSpan(
                  text: " et la ",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                TextSpan(
                  text: "politique de confidentialité",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(color: Colors.green),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () async {
                          Uri url = Uri.parse(
                            "https://eglisesetserviteursdedieu.com/privacy-policy",
                          );
                          launchUrl(url, mode: LaunchMode.inAppBrowserView);
                        },
                ),
              ],
            ),
          ),
          value: terms,
          onChanged: (bool? value) {
            setState(() {
              terms = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _addPictures() {
    return Column(
      children: [
        textDivider("Photo d'identité"),
        idPictureContainer(
          image: _schema.idPicture,
          onPressed: () async {
            try {
              var pick = await _pickImage();
              setState(() {
                _schema.idPicture = pick;
              });
            } catch (e) {
              MessageService.showWarningMessage(e.toString());
            }
          },
        ),

        Padding(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: Column(
            children: [
              textDivider("Carte d'identité"),
              rectanglePictureContainer(
                image: _schema.idCardRecto,
                label: "Recto de la carte d'identité",
                onPressed: () async {
                  try {
                    var pick = await _pickImage();
                    setState(() {
                      _schema.idCardRecto = pick;
                    });
                  } catch (e) {
                    MessageService.showWarningMessage(e.toString());
                  }
                },
              ),
              SizedBox(height: 15),
              rectanglePictureContainer(
                image: _schema.idCardVerso,
                label: "Verso de la carte d'identité",
                onPressed: () async {
                  try {
                    var pick = await _pickImage();
                    setState(() {
                      _schema.idCardVerso = pick;
                    });
                  } catch (e) {
                    MessageService.showWarningMessage(e.toString());
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
