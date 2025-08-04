import 'package:aesd/appstaticdata/dictionnary.dart';
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
  final _formKey = GlobalKey<FormState>();

  // controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _managerController = TextEditingController();

  bool terms = false;
  String? _call;
  String accountType = Dictionnary.faithFul.code;

  @override
  Widget build(BuildContext context) {
    return authContainer(
      title: "Inscription",
      subtitle: "Remplissez les champs pour créer votre compte",
      child: Form(
        key: _formKey,
        child: Column(
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
                  value: accountType.code, child: Text(accountType.name)
                );
              })
            ),

            if (accountType == Dictionnary.servant.code)
              CustomDropdownButton(
                  label: "Quel est votre appel ?",
                  value: _call ?? "",
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
                    return DropdownMenuItem(
                      value: call.code, child: Text(call.name)
                    );
                  })
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

            if (accountType == Dictionnary.singer.code)
              ...[
                CustomFormTextField(
                  controller: _managerController,
                  label: "Manager",
                  prefix: cusIcon(FontAwesomeIcons.userTie),
                  validate: true,
                ),

                MultilineField(
                  controller: _descriptionController,
                  label: "Description"
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
              validate: true
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
              onPressed: () {
                if (_formKey.currentState!.validate()){
                  print("Formulaire valide !");
                }
              },
            ),
          ],
        ),
      )
    );
  }
}
