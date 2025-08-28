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

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future submit() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Auth>(context, listen: false)
        .forgotPassword(email: _emailController.text);
    } on DioException catch(e) {
      e.printError();
      MessageService.showErrorMessage("Erreur réseau vérifiez votre internet et réessayez");
    } on HttpException catch (e) {
      MessageService.showWarningMessage(e.message);
    } catch(e){
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendu s'est produite !");
    } finally {
      setState(() {
        _isLoading = false;
      });
      Get.toNamed(
        Routes.verifyEmail,
        arguments: _emailController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            title: "Mot de passe oublié",
            subtitle:
                "Entrez votre email, nous ferons des vérification "
                "et vous pourrez modifier votre mot de passe",
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/illustrations/forgot-password.svg",
                        height: 180,
                        width: 160,
                      ),
                    ),
                  ),
                  EmailField(
                    label: "Adresse email",
                    controller: _emailController,
                    validate: true,
                  ),

                  CustomElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()){
                        await submit();
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
