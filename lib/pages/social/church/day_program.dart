import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/pages/social/socialElementsList.dart';
import 'package:aesd/provider/event.dart';
import 'package:aesd/provider/program.dart';
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
  bool _isLoading = false;

  Future init() async {
    try {
      setState(() => _isLoading = true);
      await Provider.of<Event>(
        context,
        listen: false,
      ).getEvents(churchId: widget.churchId);
      await Provider.of<ProgramProvider>(
        context,
        listen: false,
      ).getChurchPrograms(widget.churchId);
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Veuillez vérifier votre connexion internet.",
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future loadPrograms() async {
    await Provider.of<ProgramProvider>(
      context,
      listen: false,
    ).getChurchPrograms(widget.churchId);
    return Provider.of<ProgramProvider>(context, listen: false).dayPrograms;
  }

  /*Future loadEvents() async {
    await Provider.of<Event>(
      context,
      listen: false,
    ).getEvents(churchId: widget.churchId);
    return Provider.of<Event>(context, listen: false).events;
  }*/

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await init();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Programme",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 20),

          Consumer<ProgramProvider>(
            builder: (context, provider, child) {
              if (provider.dayPrograms.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: notFoundTile(text: "Aucun programme à afficher"),
                );
              }
              final programs = provider.dayPrograms;
              return Column(
                children: List.generate(programs.length, (index) {
                  final program = programs[index];
                  return program.buildWidget(
                    context,
                    reloader: () => setState(() {}),
                  );
                }),
              );
            },
          ),

          SizedBox(height: 10),

          /*_buildHeaderRow(
            text: "Evénements",
            onTap:
                () => Get.to(() =>
                  SocialElementsList(loadElements: () => loadEvents()),
                ),
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
                child: provider.events[0].buildWidget(context),
              );
            },
          ),*/
        ],
      ),
    );
  }

  Widget _buildHeaderRow({required String text, void Function()? onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              "voir plus",
              style: TextStyle(
                color: notifire.getMainColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
