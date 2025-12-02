import 'dart:convert';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/functions/launcher.dart';
import 'package:aesd/models/ceremony.dart';
import 'package:aesd/services/message.dart';
import 'package:chewie/chewie.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
//import 'package:aesd/provider/cinetpay.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../provider/ceremonies.dart';

class CeremonyViewer extends StatefulWidget {
  const CeremonyViewer({super.key, this.ceremony});

  final CeremonyModel? ceremony;

  @override
  State<CeremonyViewer> createState() => _CeremonyViewerState();
}

class _CeremonyViewerState extends State<CeremonyViewer> {
  CeremonyModel? ceremony;
  final _formKey = GlobalKey<FormState>();
  // controlleur du montant du don
  final amountController = TextEditingController();
  bool isLoading = true;

  // video controllers
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  void initializeVideo(String videoUrl) {
    try {
      // initialisation du controller de vidéo
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      _videoPlayerController.initialize();

      // initialisation du conteneur de vidéo personnalisé
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      );
    } catch (e) {
      //
    }
    setState(() {});
  }

  Future<dynamic> makeDonation() async {
    try {
      setState(() {
        isLoading = true;
      });

      // vérifier que le formulaire a été validé
      if (!_formKey.currentState!.validate()) {
        return MessageService.showErrorMessage("Entrez un montant correct !");
      }

      // initier un paiement cinetpay
      /*var response =
          await Provider.of<CinetPay>(context, listen: false).makePayment(
        context,
        amount: int.parse(amountController.text),
        description: "description",
        notifyUrl:
            "https://www.eglisesetserviteursdedieu.com/api/v1/notifyPayment",
        returnUrl: "https://www.eglisesetserviteursdedieu.com/api/v1/returnUrl",
      );

      // valeur de retour en fonction de la reponse reçu
      if (response.statusCode == 200) {
        // If the server returns an OK response, parse the JSON
        var json = jsonDecode(response.body);
        var data = json["data"];
        Uri paymentUrl = Uri.parse(data['payment_url']);
        uriLauncher(paymentUrl);
      }*/
    } catch (e) {
      e.printError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadCeremony(int id) async {
    try {
      await Provider.of<Ceremonies>(
        context,
        listen: false,
      ).ceremonyDetail(id).then((value) {
        ceremony =
            Provider.of<Ceremonies>(context, listen: false).selectedCeremony;
        initializeVideo(ceremony!.video);
      });
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. vérifiez votre connexion internet",
      );
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu s'est produite !");
      e.printError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      int ceremonyId = Get.arguments['ceremonyId'];
      await loadCeremony(ceremonyId);
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    if (isLoading) {
      return Scaffold(body: SafeArea(child: ListShimmerPlaceholder()));
    }

    return Scaffold(
      appBar: AppBar(leading: customBackButton(), title: Text(ceremony!.title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDate(ceremony!.date, withTime: false),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: notifire.getMainText,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              ceremony!.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: notifire.getMainText),
            ),

            // la vidéo
            if (_chewieController != null)
              Container(
                height: size.height * .3,
                width: size.width,
                margin: EdgeInsets.symmetric(vertical: 20),
                child: Chewie(controller: _chewieController!),
              ),

            if (_chewieController == null)
              const Center(child: Text("La vidéo n'est pas disponible !")),

            // partie des offrandes
            /*Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: CustomFormTextField(
                      label: "Combien voulez vous offrir",
                      type: TextInputType.number,
                      controller: amountController,
                      onChanged: (value) {
                        if (value != null) {
                          if (int.tryParse(value) == null) {
                            return MessageService.showWarningMessage(
                              "Renseignez une valeur entière",
                            );
                          }
                        }
                      },
                      validate: true,
                      validator: (value) {
                        if (int.tryParse(value!) == null) {
                          return "Entrez une valeur entière uniquement !";
                        }
                        if (int.parse(value) % 5 != 0) {
                          return "Le montant doit être multiple de 5 !";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Fr",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),*/

            /*CustomElevatedButton(
              text: "Faire mon offrande",
              icon: cusFaIcon(FontAwesomeIcons.moneyBillWave),
              onPressed: () async {
                await makeDonation();
              },
            ),*/
          ],
        ),
      ),
    );
  }
}
