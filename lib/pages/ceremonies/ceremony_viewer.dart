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
import 'package:aesd/provider/cinetpay.dart';
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
      var response =
          await Provider.of<CinetPay>(context, listen: false).makePayment(
        context,
        amount: int.parse(amountController.text),
        description: "Offrande pour ${ceremony!.title}",
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
      }
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

            // Section Donation Moderne
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    appMainColor.withOpacity(0.05),
                    appMainColor.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: appMainColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header avec icône
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [appMainColor, appMainColor.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: appMainColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: cusFaIcon(
                            FontAwesomeIcons.handHoldingHeart,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Faire une offrande",
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: notifire.getMainText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Soutenez cette cérémonie",
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: notifire.getMainText.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Formulaire de montant moderne
                    Form(
                      key: _formKey,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TextFormField(
                                  controller: amountController,
                                  keyboardType: TextInputType.number,
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: appMainColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Montant",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 18,
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: cusFaIcon(
                                        FontAwesomeIcons.coins,
                                        color: appMainColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (int.tryParse(value) == null) {
                                      return MessageService.showWarningMessage(
                                        "Renseignez une valeur entière",
                                      );
                                    }
                                  },
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
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: appMainColor.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                "XOF",
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: appMainColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bouton de donation moderne avec gradient
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              appMainColor,
                              const Color(0xff2a9000),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: appMainColor.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await makeDonation();
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  cusFaIcon(
                                    FontAwesomeIcons.heart,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Faire mon offrande",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
