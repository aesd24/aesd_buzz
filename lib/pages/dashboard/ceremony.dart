import 'dart:io';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/pages/ceremonies/create.dart';
import 'package:aesd/provider/ceremonies.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class CeremoniesManagement extends StatefulWidget {
  const CeremoniesManagement({super.key, required this.churchId});

  final int churchId;

  @override
  State<CeremoniesManagement> createState() => _CeremoniesManagementState();
}

class _CeremoniesManagementState extends State<CeremoniesManagement> {
  bool _isLoading = false;

  Future<void> init() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Ceremonies>(
        context,
        listen: false,
      ).all(churchId: widget.churchId);
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau, vérifiez votre connexion internet et rééssayez",
      );
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendu est survenu !");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future handleDeletion(element) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Ceremonies>(
        context,
        listen: false,
      ).delete(element: element).then((value) {
        MessageService.showSuccessMessage("Suppréssion éffectué !");
      });
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
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
    init();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: FaIcon(FontAwesomeIcons.xmark, size: 20),
          ),
          centerTitle: true,
          title: Text('Ceremonies', style: TextStyle(fontSize: 20)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              CustomElevatedButton(
                text: "Ajouter une cérémonie",
                icon: FaIcon(FontAwesomeIcons.film, color: Colors.white),
                onPressed:
                    () => Get.to(() =>CeremonyForm(churchId: widget.churchId)),
              ),
              CustomFormTextField(
                prefix: Icon(Icons.search),
                label: "Rechercher",
              ),
              SizedBox(height: 10),
              Consumer<Ceremonies>(
                builder: (context, ceremonyProvider, child) {
                  return Expanded(
                    child:
                        ceremonyProvider.ceremonies.isNotEmpty
                            ? SingleChildScrollView(
                              child: Column(
                                children: List.generate(
                                  ceremonyProvider.ceremonies.length,
                                  (index) {
                                    var current =
                                        ceremonyProvider.ceremonies[index];
                                    return current.card(
                                      context,
                                      dashboardAccess: true,
                                      onDelete: () => handleDeletion(current),
                                    );
                                  },
                                ),
                              ),
                            )
                            : Center(
                              child: Text(
                                "Aucune cérémonie disponible",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
