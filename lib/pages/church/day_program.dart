import 'dart:io';

import 'package:aesd/components/snack_bar.dart';
import 'package:aesd/models/day_program.dart';
import 'package:aesd/models/event.dart';
import 'package:aesd/providers/event.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class Program extends StatefulWidget {
  const Program({super.key, required this.churchId});

  final int churchId;

  @override
  State<Program> createState() => _ProgramState();
}

class _ProgramState extends State<Program> {
  var currentProgram = DayProgramModel.fromJson({
    'day': "Lundi",
    'program': List.generate(3, (index) {
      return {
        'title': "Programme $index",
        'startTime': "${index + 10}:00:00",
        'endTime': "${index + 11}:00:00",
        'place': "Lien $index"
      };
    })
  });

  /* var lastEvent = EventModel.fromJson({
    'id': 0,
    'titre':"Intitulé de l'évènement 1",
    'date_debut': DateTime.now(),
    'date_fin': DateTime.now(),
  }); */

  void init() async {
    try {
      await Provider.of<Event>(context, listen: false).getEvents(churchId: widget.churchId);
    } on HttpException catch (e) {
      showSnackBar(
        context: context,
        message: e.message,
        type: SnackBarType.danger
      );
    } on DioException {
      showSnackBar(
        context: context,
        message: "Erreur réseau. Veuillez vérifier votre connexion internet.",
        type: SnackBarType.danger
      );
    } catch (e) {
      e.printError();
      showSnackBar(
        context: context,
        message: "Une erreur inattendue s'est produite !",
        type: SnackBarType.danger
      );
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Programme du jour",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              /* TextButton.icon(
                  onPressed: () => null,//NavigationService.push(context, destination: ),
                  icon: const Icon(Icons.keyboard_arrow_right),
                  iconAlignment: IconAlignment.end,
                  label: const Text("Tout voir")) */
            ],
          ),
          Consumer<Event>(
            builder: (context, eventProvider, child){
              EventModel? lastEvent;
              if (eventProvider.events.isNotEmpty) {
                lastEvent = eventProvider.events.last;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: lastEvent != null ? 
                  lastEvent.getWidget(context) :
                  Text("Aucun événement pour le moment..."),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: currentProgram.getWidget(context),
          )
        ],
      ),
    );
  }
}