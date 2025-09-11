import 'package:aesd/components/field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CeremoniesPage extends StatefulWidget {
  const CeremoniesPage({super.key});

  @override
  State<CeremoniesPage> createState() => _CeremoniesPageState();
}

class _CeremoniesPageState extends State<CeremoniesPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: customTextField(
            prefixIcon: const Icon(Icons.search),
            suffix: PopupMenuButton(
                icon: const FaIcon(
                  FontAwesomeIcons.sort,
                  color: Colors.grey,
                ),
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(value: "1", child: Text("Trier par truc")),
                    PopupMenuItem(value: "2", child: Text("Trier par mouman")),
                    PopupMenuItem(value: "3", child: Text("Trier par ken")),
                  ];
                }),
            label: "Rechercher",
          ),
        ),
        Column(
          children: List.generate(10, (index) {
            return Card(
              elevation: 0,
              color: Colors.green.shade50,
              child: ListTile(
                title: Text("Titre de la cérémonie $index"),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("1/${index + 1}/2024"), const Text("Durée: 1h30")],
                ),
              ),
            );
          }),
        )
      ],
    ));
  }
}
