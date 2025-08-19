import 'dart:io';
import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/containers.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/schemas/user.dart';
import 'package:aesd/services/message.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.loadingCallBack});

  final void Function()? loadingCallBack;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<String> _getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.model;
    } else {
      return "Appareil inconnu";
    }
  }

  Future<void> _login(String? token) async {
    print("Djoorrr!!");
    try {
      widget.loadingCallBack!();
      final schemas = UserLogin(
        login: _loginController.text,
        password: _passwordController.text,
        deviceName: await _getDeviceName(),
        deviceToken: token ?? "",
      );

      await Provider.of<Auth>(context, listen: false).login(schemas).then((
        value,
      ) async {
        if (value) {
          MessageService.showSuccessMessage("Connexion reussi !");
          Get.toNamed(Routes.homepage);
        }
      });
    } on HttpException catch (e) {
      MessageService.showWarningMessage(e.message);
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      MessageService.showErrorMessage(
        "Remplissez correctement le formulaire s'il vous plait !",
      );
    } else {
      FocusScope.of(context).unfocus();

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission();
      String? token;

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        //token = await messaging.getToken();
        await _login(token);
      } else {
        MessageService.showWarningMessage(
          "La permission pour les notifications est requise. Rééssayez !",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return authContainer(
      title: "Connexion",
      subtitle:
          "Veuillez entrer votre e-mail/numéro de téléphone et votre mot de passe",
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomFormTextField(
              controller: _loginController,
              label: "Login",
              prefix: cusIcon(FontAwesomeIcons.solidUser),
              validate: true,
            ),
            PasswordField(validate: true, controller: _passwordController),
            CustomElevatedButton(
              text: "Continuer",
              icon: cusIcon(FontAwesomeIcons.arrowRight, color: Colors.white),
              onPressed: () async => await _handleLogin(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    Get.toNamed(Routes.forgot);
                  },
                  child: Text(
                    "Mot de passe oublié?",
                    style: TextStyle(fontSize: 12, color: appMainColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
