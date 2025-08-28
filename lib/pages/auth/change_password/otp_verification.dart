import 'dart:io';

import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/containers.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  bool _isLoading = false;
  String code = "";

  Future verifyOTPCode(String code, String email) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Auth>(
        context,
        listen: false,
      ).verifyOtp(otpCode: code).then((value) {
        Get.toNamed(Routes.changePassword, arguments: email);
      });
    } on DioException catch (e) {
      e.printError();
      MessageService.showErrorMessage(
        "Erreur réseau, vérifier votre connexion internet",
      );
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendue s'est produite.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String email = Get.arguments;
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
          padding: EdgeInsets.all(15),
          child: authContainer(
            title: "Vérification de l'e-mail",
            subtitle:
                "Veuillez s'il vous plait entrer le code à 4 chiffres envoyé "
                "par e-mail",
            child: Column(
              children: [
                const SizedBox(height: 64),
                Text(
                  "Code de vérification envoyé à l'adresse :",
                  style: mediumBlackTextStyle.copyWith(
                    fontSize: 16,
                    color: notifire.getMainText,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        email,
                        style: mediumGreyTextStyle.copyWith(fontSize: 16),
                        maxLines: 2,
                      ),
                      const SizedBox(width: 10),

                      IconButton(
                        onPressed: () => Get.back(),
                        iconSize: 0,
                        icon: cusFaIcon(FontAwesomeIcons.pen),
                      ),
                    ],
                  ),
                ),
                OTPTextField(
                  length: 4,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 50,
                  style: TextStyle(fontSize: 17, color: notifire.getMainText),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  otpFieldStyle: OtpFieldStyle(
                    backgroundColor: notifire.getbgcolor,
                    enabledBorderColor: notifire.getbgcolor,
                    disabledBorderColor: notifire.getbgcolor,
                    borderColor: notifire.getbgcolor,
                  ),
                  onChanged: (value) {
                    code = value;
                  },
                  fieldStyle: FieldStyle.box,
                  onCompleted: (pin) {},
                ),
                Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: CustomElevatedButton(
                    onPressed: () async => await verifyOTPCode(code, email),
                    text: "Suivant",
                    icon: cusFaIcon(
                      FontAwesomeIcons.arrowRightLong,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
