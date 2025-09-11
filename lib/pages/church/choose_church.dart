import 'dart:io';
import 'package:aesd/components/button.dart';
import 'package:aesd/components/snack_bar.dart';
import 'package:aesd/components/field.dart';
import 'package:aesd/models/user_model.dart';
import 'package:aesd/services/navigation.dart';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/providers/church.dart';
import 'package:aesd/providers/user.dart';
import 'package:aesd/screens/church/creation/main.dart';
import 'package:aesd/screens/church/detail.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ChooseChurch extends StatefulWidget {
  const ChooseChurch({super.key});

  @override
  State<ChooseChurch> createState() => _ChooseChurchState();
}

class _ChooseChurchState extends State<ChooseChurch> {
  bool isLoading = false;
  bool throwedErrorLastTime = false;

  // liste des églises
  List<ChurchModel> churchList = [];

  //controller
  final searchController = TextEditingController();

  // fonction de filtre des églises a partir de la recherche
  List getList() {
    String text = searchController.text;

    // variable à retourner
    List returned = [];

    // boucle sur la liste
    if (text.isNotEmpty) {
      for (var element in churchList) {
        if (element.name.toLowerCase().contains(text.toLowerCase())) {
          returned.add(element);
        }
      }
    } else {
      return churchList;
    }
    return returned;
  }
  
  Future loadChurches() async {
    // Load churches from API
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Church>(context, listen: false).fetchChurches();
      churchList = Provider.of<Church>(context, listen: false).churches;
      setState(() {});
    } on DioException {
      showSnackBar(
          context: context,
          message: "Vérifiez votre connexion internet",
          type: SnackBarType.danger);
      setState(() {
        throwedErrorLastTime = true;
      });
    } on HttpException catch (e) {
      e.printError();
      showSnackBar(
          context: context, message: e.message, type: SnackBarType.danger);
      setState(() {
        throwedErrorLastTime = true;
      });
    } catch (e) {
      e.printError();
      showSnackBar(
          context: context,
          message: "Une erreur inattendue est survenue !",
          type: SnackBarType.danger);
      setState(() {
        throwedErrorLastTime = true;
      });
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
    UserModel user = Provider.of<User>(context).user!;

    return Scaffold(
      appBar: AppBar(title: const Text("Choisir une église")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recherche et nouvelle églises
              if (user.accountType == "serviteur_de_dieu")
                customButton(
                    context: context,
                    text: "Ajouter mon église",
                    trailing:
                        const Icon(Icons.church_outlined, color: Colors.white),
                    onPressed: () => NavigationService.push(MainChurchCreationPage())),

              // input de recherche
              customTextField(
                  label: "Entrez votre recherche",
                  controller: searchController,
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) {
                    getList();
                    setState(() {});
                  }),

              // liste des églises
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Builder(builder: (context) {
                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return churchList.isNotEmpty
                        ? Column(
                            children: List.generate(getList().length, (value) {
                            if (getList().isNotEmpty) {
                              ChurchModel church = getList()[value];
                              return GestureDetector(
                                onTap: () => NavigationService.push(
                                  ChurchDetailPage(churchId: church.id)
                                ),
                                child: church.card(context),
                              );
                            } else {
                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                ),
                                alignment: Alignment.center,
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.search_off, size: 60),
                                    Text(
                                        "Aucune résultat correspondant à la recherche !")
                                  ],
                                ),
                              );
                            }
                          }))
                        : Center(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.search_off, size: 60),
                                  const Text(
                                      "Aucune église disponible pour le moment !"),
                                  const SizedBox(height: 30),
                                  if (throwedErrorLastTime)
                                    customButton(
                                        context: context,
                                        onPressed: () async =>
                                            await loadChurches(),
                                        text: "Rééssayer",
                                        trailing: const FaIcon(
                                          FontAwesomeIcons.arrowRotateRight,
                                          color: Colors.white,
                                        ))
                                ],
                              ),
                            ),
                          );
                  }
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
