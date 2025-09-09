import 'dart:io';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/components/structure.dart';
import 'package:aesd/provider/event.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class EventsList extends StatefulWidget {
  const EventsList({super.key});

  @override
  State<EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  bool isLoading = false;

  Future loadEvents() async {
    try {
      setState(() {
        isLoading = true;
      });
      //await Provider.of<Event>(context, listen: false).getAll();
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage("Erreur réseau. Vérifiez votre connexion internet");
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendu s'est produite.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: CustomFormTextField(
                label: "Recherche",
                prefix: cusIcon(Icons.search),
              ),
            ),
            Expanded(
              child: isLoading ? ListShimmerPlaceholder() : Consumer<Event>(
                builder: (context, provider, child) {
                  if (provider.events.isEmpty) {
                    return notFoundTile(text: "Aucun évènement trouvé");
                  }
                  return RefreshIndicator(
                    onRefresh: () async {}, //=> await loadEvents(),
                    child: ListView.builder(
                      itemCount: provider.events.length,
                      itemBuilder: (context, index) {
                        var current = provider.events[index];
                        return current.buildWidget(context);
                      },
                    ),
                  );
                },
              ),
            ),
            if (isLoading) loadingBar(),
          ],
        ),
      ],
    );
  }
}
