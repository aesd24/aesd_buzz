import 'package:aesd/components/fields.dart';
import 'package:aesd/provider/ceremonies.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CeremonyList extends StatefulWidget {
  const CeremonyList({super.key});

  @override
  State<CeremonyList> createState() => _CeremonyListState();
}

class _CeremonyListState extends State<CeremonyList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des cérémonies"),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            CustomFormTextField(
              label: "Rechercher",
              prefix: const Icon(Icons.search)
            ),
            Consumer<Ceremonies>(
              builder: (context, ceremonyProvider, child) {
                return ceremonyProvider.ceremonies.isNotEmpty ? Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {},
                    child: ListView.builder(
                      itemCount: ceremonyProvider.ceremonies.length,
                      itemBuilder: (context, index){
                        var current = ceremonyProvider.ceremonies[index];
                        return current.card(context);
                      }
                    ),
                  ),
                ) : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    "Aucune cérémonie disponible",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                );
              }
            )
          ],
        ),
      ),
    );
  }
}