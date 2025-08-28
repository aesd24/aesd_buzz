import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/bottom_sheets.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/containers.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class UpdateUserPage extends StatefulWidget {
  const UpdateUserPage({super.key});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool displayImage = false;

  File? image;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  Future modifyInformation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Auth>(context, listen: false)
          .modifyInformation({
            "name": _nameController.text,
            "email": _emailController.text,
            "phone": _phoneController.text,
            "adresse": _addressController.text,
          })
          .then((value) {
            MessageService.showSuccessMessage("Modification éffectué !");
            Get.back();
          });
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau vérifiez votre connexion internet !",
      );
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendue est survenue !");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    displayImage =
        Provider.of<Auth>(context, listen: false).user!.photo != null;
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(image);
    print(displayImage);
    return LoadingOverlay(
      isLoading: isLoading,
      progressIndicator: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 1.5,
      ),
      child: Scaffold(
        appBar: AppBar(leading: customBackButton()),
        body: Consumer<Auth>(
          builder: (context, auth, child) {
            final user = auth.user!;
            _nameController.text = user.name;
            _emailController.text = user.email;
            _phoneController.text = user.phone;
            _addressController.text = user.adress;

            return Padding(
              padding: EdgeInsets.all(15),
              child: authContainer(
                title: "Modifier mes informations",
                subtitle: "Veuillez remplir le formulaire ci-dessous",
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 30),
                        child: GestureDetector(
                          onTap:
                              () => pickModeSelectionBottomSheet(
                                context: context,
                                setter: (file) {
                                  if (file != null) {
                                    setState(() {
                                      image = file;
                                      displayImage = true;
                                    });
                                  }
                                },
                              ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: notifire.getMaingey,
                            backgroundImage:
                                displayImage
                                    ? image != null
                                        ? FileImage(image!)
                                        : FastCachedImageProvider(user.photo!)
                                    : null,
                            child:
                                !displayImage
                                    ? cusFaIcon(
                                      FontAwesomeIcons.camera,
                                      size: 40,
                                    )
                                    : null,
                          ),
                        ),
                      ),

                      _form(),
                      SizedBox(height: 15),
                      CustomElevatedButton(
                        text: "Valider les modifications",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            modifyInformation();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
