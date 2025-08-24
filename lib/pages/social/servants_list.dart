import 'dart:io';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/provider/servant.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ServantsList extends StatefulWidget {
  const ServantsList({super.key});

  @override
  State<ServantsList> createState() => _ServantsListState();
}

class _ServantsListState extends State<ServantsList> {
  bool isLoading = false;

  Future loadServants() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Servant>(context, listen: false).fetchServants();
    } on DioException {
      MessageService.showErrorMessage("Erreur réseau, vérifiez votre connexion internet");
    } on HttpException catch(e) {
      MessageService.showErrorMessage(e.message);
    } catch(e) {
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
    loadServants();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? ListShimmerPlaceholder() : Consumer<Servant>(
        builder: (context, provider, child) {
          if (provider.servants.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: RefreshIndicator(
                  onRefresh: () async => loadServants(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      notFoundTile(text: "Aucun serviteur pour le moment"),
                    ],
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => loadServants(),
            child: ListView.builder(
              itemCount: provider.servants.length,
              itemBuilder: (context, index) {
                return provider.servants[index].buildCard(context);
              },
            ),
          );
        }
    );
  }
}
