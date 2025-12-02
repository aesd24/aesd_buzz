import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/services/message.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class RetryValidateChurch extends StatefulWidget {
  const RetryValidateChurch({super.key, required this.churchId});

  final int churchId;

  @override
  State<RetryValidateChurch> createState() => _RetryValidateChurchState();
}

class _RetryValidateChurchState extends State<RetryValidateChurch> {
  bool _isLoading = false;

  File? _attestationFile;
  Future<void> getAttestation() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      _attestationFile = File(result.files.single.path!);
    }
    setState(() {});
  }

  Future<void> handleSubmit() async {
    if (_attestationFile == null) {
      return MessageService.showWarningMessage(
        "Veuillez ajouter le fichier svp",
      );
    }

    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Church>(
        context,
        listen: false,
      ).retryValidateChurch(widget.churchId, _attestationFile!).then((result) {
        if (result) {
          MessageService.showSuccessMessage(
            "L'attestation a été envoyée avec succès",
          );
          Provider.of<Church>(context, listen: false).getUserChurches();
          Provider.of<Auth>(context, listen: false).getUserData();
          Get.back();
        }
      });
    } catch (e) {
      e.printError();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .4,
      padding: EdgeInsets.only(top: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: notifire.getbgcolor,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: customBackButton(icon: FontAwesomeIcons.xmark),
          title: Text(
            "Valider mon église",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: notifire.getMainText),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child:
                  _isLoading
                      ? CircularProgressIndicator(strokeWidth: 1.5)
                      : CustomTextButton(
                        label: 'Envoyer',
                        onPressed: () async => await handleSubmit(),
                        type: ButtonType.success.copyWith(
                          icon: cusFaIcon(
                            FontAwesomeIcons.paperPlane,
                            color: Colors.white,
                          ),
                        ),
                      ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async => await getAttestation(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 15,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color:
                          _attestationFile == null ? Colors.grey : Colors.green,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      _attestationFile == null
                          ? const FaIcon(FontAwesomeIcons.fileCirclePlus)
                          : const FaIcon(
                            FontAwesomeIcons.circleCheck,
                            color: Colors.green,
                          ),
                      const SizedBox(width: 20),
                      Flexible(
                        child: Text(
                          _attestationFile == null
                              ? "Chargez l'attestation d'existance"
                              : "Attestation chargé !",
                          style:
                              _attestationFile != null
                                  ? const TextStyle(color: Colors.green)
                                  : null,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 20),
                child: Text(
                  "Chargez un fichier au format PDF de moins de 2 Go",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
