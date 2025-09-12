import 'dart:io';

import 'package:aesd/components/fields.dart';
import 'package:aesd/models/ceremony.dart';
import 'package:aesd/provider/ceremonies.dart';
import 'package:aesd/pages/ceremonies/list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../services/message.dart';

class CeremonyShortList extends StatefulWidget {
  const CeremonyShortList({super.key, required this.churchId});

  final int churchId;

  @override
  State<CeremonyShortList> createState() => _CeremonyShortListState();
}

class _CeremonyShortListState extends State<CeremonyShortList> {
  Future<void> init() async {
    try {
      await Provider.of<Ceremonies>(
        context,
        listen: false,
      ).all(churchId: widget.churchId);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur de connexion. Vérifiez votre connexion internet",
      );
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendue est survenue !");
      e.printError();
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomFormTextField(
            label: "Rechercher",
            prefix: const Icon(Icons.search),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Get.to(CeremonyList()),
              label: const Text("Voir plus"),
              icon: const Icon(Icons.add),
              iconAlignment: IconAlignment.end,
            ),
          ),
          Consumer<Ceremonies>(
            builder: (context, ceremonyProvider, child) {
              List<CeremonyModel> eventList =
                  ceremonyProvider.ceremonies.reversed
                      .toList()
                      .take(5)
                      .toList();
              return eventList.isNotEmpty
                  ? Column(
                    children: List.generate(eventList.length, (index) {
                      var current = eventList[index];
                      return current.card(context);
                    }),
                  )
                  : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      "Aucune cérémonie disponible",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }
}
