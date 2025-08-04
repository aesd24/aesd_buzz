import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/containers.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: cusFaIcon(FontAwesomeIcons.arrowLeftLong),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: authContainer(
          title: "Mot de passe oublié",
          subtitle: "Entrez votre email, nous ferons des vérification et vous pourrez modifier votre mot de passe",
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/illustrations/forgot-password.svg",
                    height: 180,
                    width: 160
                  )
                ),
              ),
              CustomFormTextField(
                label: "Adresse email",
                prefix: cusIcon(FontAwesomeIcons.at)
              ),
              CustomElevatedButton(
                text: "Continuer",
                icon: cusFaIcon(
                  FontAwesomeIcons.arrowRightLong,
                  color: Colors.white
                )
              )
            ]
          )
        ),
      ),
    );
  }
}
