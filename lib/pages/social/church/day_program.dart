import 'dart:io';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/models/day_program.dart';
import 'package:aesd/models/event.dart';
import 'package:aesd/provider/event.dart';
import 'package:aesd/services/message.dart';
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
        'place': "Lien $index",
      };
    }),
  });

  void init() async {
    try {
      await Provider.of<Event>(
        context,
        listen: false,
      ).getEvents(churchId: widget.churchId);
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Veuillez vérifier votre connexion internet.",
      );
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendue s'est produite !");
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Liste des événements",
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          Consumer<Event>(
            builder: (context, provider, child) {
              final events = provider.events;
              if (events.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: notFoundTile(text: "Aucun événement à afficher"),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: List.generate(events.length, (index) {
                    return events[index].buildWidget(context);
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
