import 'dart:io';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendue est survenue !");
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
    return isLoading ? ListShimmerPlaceholder() : Consumer<Church>(
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
        return RefreshIndicator(
          onRefresh: () async => loadChurches(),
          child: ListView.builder(
            itemCount: provider.churches.length,
            itemBuilder: (context, index) {
              return provider.churches[index].buildWidget(context);
            },
          ),
        );
      }
    );
  }
}
