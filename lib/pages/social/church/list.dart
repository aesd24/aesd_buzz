import 'dart:io';
import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/pages/social/church/creation/main.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ChurchList extends StatefulWidget {
  const ChurchList({super.key});

  @override
  State<ChurchList> createState() => _ChurchListState();
}

class _ChurchListState extends State<ChurchList> {
  bool isLoading = false;

  Future loadChurches() async {
    // Load churches from API
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Church>(context, listen: false).fetchChurches();
    } on DioException catch (e) {
      e.printError();
      MessageService.showErrorMessage(
        "Erreur réseau, vérifiez votre connexion internet",
      );
    } on HttpException catch (e) {
      e.printError();
      MessageService.showErrorMessage(e.message);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadChurches();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? ListShimmerPlaceholder()
        : Stack(
          children: [
            Consumer<Church>(
              builder: (context, provider, child) {
                if (provider.churches.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      child: RefreshIndicator(
                        onRefresh: () async => loadChurches(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            notFoundTile(text: "Aucune eglise trouvée"),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final churches = provider.churches;

                return RefreshIndicator(
                  onRefresh: () async => loadChurches(),
                  child: ListView.builder(
                    itemCount: churches.length,
                    itemBuilder: (context, index) {
                      return churches[index].buildWidget(context);
                    },
                  ),
                );
              },
            ),
            Consumer<Auth>(
              builder: (context, provider, child) {
                final user = provider.user;
                // bouton flottant pour ajout d'église
                if (user != null &&
                    user.accountType.code == Dictionnary.servant.code) {
                  return Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        backgroundColor: notifire.getMainColor,
                        onPressed: () {
                          if (user.certifStatus !=
                              CertificationStates.approved) {
                            return MessageService.showWarningMessage(
                              "Votre compte n'est pas validé vous n'avez pas les accès requis !",
                            );
                          }
                          Get.to(MainChurchCreationPage());
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 3,
                        child: cusFaIcon(
                          FontAwesomeIcons.plus,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
                return SizedBox();
              },
            ),
          ],
        );
  }
}
