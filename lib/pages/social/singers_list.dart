import "dart:io";

import "package:aesd/components/not_found.dart";
import "package:aesd/components/placeholders.dart";
import "package:aesd/provider/singer.dart";
import "package:aesd/services/message.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:get/get.dart";
import "package:provider/provider.dart";

class SingersList extends StatefulWidget {
  const SingersList({super.key});

  @override
  State<SingersList> createState() => _SingersListState();
}

class _SingersListState extends State<SingersList> {
  bool isLoading = false;

  Future loadSingers() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Singer>(context, listen: false).fetchSingers();
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau, vérifiez votre connexion internet",
      );
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu est survenu !");
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
    loadSingers();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? ListShimmerPlaceholder()
        : Consumer<Singer>(
          builder: (context, provider, child) {
            if (provider.singers.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  child: RefreshIndicator(
                    onRefresh: () async => loadSingers(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        notFoundTile(
                          icon: FontAwesomeIcons.microphone,
                          text: "Aucun chantre pour le moment"
                        )
                      ]
                    )
                  )
                )
              );
            }
            return RefreshIndicator(
              onRefresh: () async => loadSingers(),
              child: ListView.builder(
                itemCount: provider.singers.length,
                itemBuilder: (context, index) {
                  return provider.singers[index].buildCard(context);
                },
              ),
            );
          },
        );
  }
}
