import 'dart:convert';
import 'package:aesd/models/ceremony.dart';
import 'package:chewie/chewie.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
//import 'package:aesd/provider/cinetpay.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
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
  bool isLoading = false;

  // video controllers
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  initializeVideo(String videoUrl) {
    try {
      // initialisation du controller de vidéo
      _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl));
      _videoPlayerController.initialize();

      // initialisation du conteneur de vidéo personnalisé
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ],
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      );
    } catch (e) {
      //
    }
    setState(() {});
  }

  makeDonation() async {
    try {
      setState(() {
        isLoading = true;
      });

      // vérifier que le formulaire a été validé
      if (!_formKey.currentState!.validate()) {
        return showSnackBar(
            context: context,
            message: "Entrez un montant correct !",
            type: SnackBarType.danger);
      }

      // initier un paiement cinetpay
      var response =
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
        NavigationService.push(
          CustomWebView(
            url: paymentUrl.toString(),
            title: "Faire un paiement",
          )
        );
      }
    } catch (e) {
      e.printError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  loadCeremony(int id) async {
    try {
      await Provider.of<Ceremonies>(context, listen: false).ceremonyDetail(
        id
      ).then((value) {
        ceremony = Provider.of<Ceremonies>(context, listen: false).selectedCeremony;
        initializeVideo(ceremony!.video);
      });
    } on DioException {
      showSnackBar(
          context: context,
          message: "Erreur réseau. vérifiez votre connexion internet",
          type: SnackBarType.danger
      );
    } catch(e) {
      showSnackBar(
          context: context,
          message: "Une erreur inattendu s'est produite !",
          type: SnackBarType.danger
      );
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
    setState(() {
      isLoading = true;
    });
    if (widget.ceremony != null) {
      ceremony = widget.ceremony;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (ceremony == null) {
        int ceremonyId = ModalRoute.of(context)!.settings.arguments as int;
        await loadCeremony(ceremonyId);
      }
      setState(() {
        isLoading = false;
      });
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
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
          appBar: ceremony == null ? null : AppBar(title: Text(ceremony!.title)),
          body: ceremony == null ? Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
            ),
          ) : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${ceremony!.date.day}/${ceremony!.date.month}/${ceremony!.date.year}",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ceremony!.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.black45),
                    ),

                    const SizedBox(height: 15),

                    // la vidéo
                    if (_chewieController != null)
                      SizedBox(
                        height: size.height * .3,
                        width: size.width,
                        child: Chewie(controller: _chewieController!),
                      ),

                    if (_chewieController == null)
                      const Center(
                          child: Text("La vidéo n'est pas disponible !")),

                    // partie des offrandes
                    Form(
                      key: _formKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: customTextField(
                                label: "Montant",
                                placeholder: "Combien voulez vous offrir ?",
                                type: TextInputType.number,
                                controller: amountController,
                                onChanged: (value) {
                                  if (int.tryParse(value) == null) {
                                    return showSnackBar(
                                        context: context,
                                        message:
                                            "Renseignez une valeur entière",
                                        type: SnackBarType.warning);
                                  }
                                },
                                validator: (value) {
                                  if (int.tryParse(value) == null) {
                                    return "Entrez une valeur entière uniquement !";
                                  }
                                  if (int.parse(value) % 5 != 0) {
                                    return "Le montant doit être multiple de 5 !";
                                  }
                                  return null;
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Fr",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),

                    customButton(
                        context: context,
                        text: "Faire une offrande",
                        onPressed: () async {
                          await makeDonation();
                        })
                  ]))),
    );
  }
}
