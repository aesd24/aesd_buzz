import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/containers.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String accountType = "0";
  final _formKey = GlobalKey<FormState>();
  bool terms = false;

  // controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return authContainer(
      title: "Inscription",
      subtitle: "Ajoutez vos informations pour créer votre compte",
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomDropdownButton(
              label: "Type de compte",
              value: "0",
              onChanged: (value) {
                print(value);
                if (value != null) {
                  setState(() {
                    accountType = value;
                  });
                }
              },
              items: List.generate(3, (index) {
                return DropdownMenuItem(value: index.toString(), child: Text("type $index"));
              })
            ),
            CustomFormTextField(
              controller: _nameController,
              label: "Nom & prénoms",
              prefix: cusIcon(FontAwesomeIcons.solidUser)
            ),
            CustomFormTextField(
              controller: _emailController,
              label: "Adresse e-mail",
              prefix: cusIcon(FontAwesomeIcons.at)
            ),
            CustomFormTextField(
              controller: _phoneController,
              label: "Numéro de téléphone",
              prefix: cusIcon(FontAwesomeIcons.phone)
            ),
            CustomFormTextField(
              controller: _addressController,
              label: "Adresse",
              prefix: cusIcon(FontAwesomeIcons.locationDot)
            ),
            PasswordField(
              controller: _passwordController,
            ),
            PasswordField(
              controller: _passwordConfirmController,
              label: "Confirmer le mot de passe"
            ),

            // termes et conditions
            CheckboxListTile(
              activeColor: Colors.green,
              checkColor: Colors.white,
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: "J'ai lu et j'accepte les ",
                        style: Theme.of(context).textTheme.labelLarge
                    ),
                    TextSpan(
                      text:"conditions générales d'utilisation",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: Colors.green),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          Uri url = Uri.parse("https://eglisesetserviteursdedieu.com/terms-of-service");
                          launchUrl(url, mode: LaunchMode.inAppBrowserView);
                        },
                    ),
                    TextSpan(
                        text: " et la ",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge),
                    TextSpan(
                      text: "politique de confidentialité",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: Colors.green),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          Uri url = Uri.parse("https://eglisesetserviteursdedieu.com/privacy-policy");
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

            CustomElevatedButton(
              text: "Continuer",
              icon: cusIcon(FontAwesomeIcons.arrowRight, color: Colors.white),
              onPressed: () async {},
            ),
          ],
        ),
      )
    );
  }
}
