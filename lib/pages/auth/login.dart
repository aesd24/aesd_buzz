import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/containers.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return authContainer(
      title: "Connexion",
      subtitle: "Veuillez entrer votre e-mail/numéro de téléphone et votre mot de passe",
      child: Column(
        children: [
          CustomFormTextField(
            label: "Login",
            prefix: cusIcon(FontAwesomeIcons.solidUser)
          ),
          PasswordField(),
          CustomElevatedButton(
            text: "Continuer",
            icon: cusIcon(FontAwesomeIcons.arrowRight, color: Colors.white),
            onPressed: () async {},
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
            )
          )
        ],
      )
    );
  }
}
