import 'dart:io';

import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/containers.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future changePassword(String email) async {
    try {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Auth>(context, listen: false).changePassword(
          email: email,
          newPassword: _passwordController.text,
          newPasswordConfirmation: _confirmPasswordController.text
      ).then((value) {
        if (value.statusCode == 200){
          if (context.mounted){
            MessageService.showSuccessMessage("Modification effectué avec succès !");
            Get.offAllNamed(Routes.auth);
          }
        }
      });
    } on DioException catch (e) {
      e.printError();
      MessageService.showErrorMessage("Erreur réseau, vérifier votre connexion internet");
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur s'est produite. Veuillez réessayer");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String email = Get.arguments;
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: cusFaIcon(FontAwesomeIcons.arrowLeftLong),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: authContainer(
            title: "Modifiez le mot de passe",
            subtitle:
            "Entrez votre nouveau mot de passe maintenant !",
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/illustrations/password.svg",
                        height: 180,
                        width: 160,
                      ),
                    ),
                  ),

                  PasswordField(
                    validate: true,
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
                    label: "Nouveau mot de passe",
                    controller: _passwordController,
                  ),

                  PasswordField(
                    validate: true,
                    label: "Confirmer le mot de passe",
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return "Les mots de passe ne correspondent pas";
                      }
                      return null;
                    },
                  ),

                  CustomElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await changePassword(email);
                      }
                    },
                    text: "Continuer",
                    icon: cusFaIcon(
                      FontAwesomeIcons.arrowRightLong,
                      color: Colors.white,
                    ),
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
