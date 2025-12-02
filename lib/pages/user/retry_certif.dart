import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/containers.dart';
import 'package:aesd/components/divider.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/image_container.dart';
import 'package:aesd/functions/camera_functions.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/schemas/user.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class RetryCertifPage extends StatefulWidget {
  const RetryCertifPage({super.key});

  @override
  State<RetryCertifPage> createState() => _RetryCertifPageState();
}

class _RetryCertifPageState extends State<RetryCertifPage> {
  final UserCertif _schema = UserCertif();
  bool isLoading = false;

  Future<void> sendDatas() async {
    try {
      setState(() => isLoading = true);
      await Provider.of<Auth>(context, listen: false).retryCertification(_schema).then((value) {
        MessageService.showSuccessMessage("Vos informations ont été transmises");
        Provider.of<Auth>(context, listen: false).getUserData();
        Get.back();
      });
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendue s'est produite !");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      progressIndicator: CircularProgressIndicator(
        strokeWidth: 1.5,
      ),
      child: Scaffold(
        appBar: AppBar(leading: customBackButton()),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: authContainer(
                    title: "Me certifier",
                    subtitle:
                        "Renvoyez vos données pour tenter encore d'être certifié",
                    child: _addPictures(),
                  ),
                ),
                SizedBox(height: 10),
                CustomElevatedButton(
                  onPressed: () async {
                    if (_schema.idPicture == null) {
                      return MessageService.showWarningMessage(
                        "Ajouter d'abord une photo d'identité",
                      );
                    }
                    if (_schema.idCardRecto == null) {
                      return MessageService.showWarningMessage(
                        "Ajouter d'abord une photo de la carte d'identité",
                      );
                    }
                    if (_schema.idCardVerso == null) {
                      return MessageService.showWarningMessage(
                        "Ajouter d'abord une photo du verso de la carte d'identité",
                      );
                    }

                    await sendDatas();
                  },
                  text: "Envoyer",
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
              var pick = await pickImage();
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
                    var pick = await pickImage();
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
                    var pick = await pickImage();
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
