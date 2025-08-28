import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  // controller
  final amountController = TextEditingController();

  // var
  String receiverType = "church";
  Object? receiver;

  selectReceiver() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Column(
              children: [
                Text(
                  "Choisissez le destinataire",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * .25,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(5, (index) {
                          return Card(
                            elevation: 0,
                            color: Colors.green,
                            child: ListTile(
                              leading: const FaIcon(
                                FontAwesomeIcons.circleUser,
                                color: Colors.white,
                              ),
                              title: Flexible(
                                child: Text(
                                  "Nom du destinataire",
                                  style: Theme.of(context).textTheme.titleSmall!
                                      .copyWith(color: Colors.white),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                              subtitle: Text(
                                "Localisation",
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(color: Colors.white60),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Envoyer de l'argent")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Image.asset("assets/icons/give.png", height: 100),
              ),

              // selection du type de destinataire
              CustomDropdownButton(
                label: "Quel est le type de destinataire",
                value: receiverType,
                items: const [
                  DropdownMenuItem(value: "church", child: Text("Une église")),
                  DropdownMenuItem(
                    value: "servant",
                    child: Text("Un serviteur de Dieu"),
                  ),
                ],
                onChanged: (value) {},
              ),

              // bouton d'affichage de la liste des destinataires
              GestureDetector(
                onTap: () => selectReceiver(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(width: 2, color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "Choisissez le destinataire",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Montant de la transaction
              CustomFormTextField(
                label: "Montant",
                type: TextInputType.number,
                controller: amountController,
              ),

              // bouton envoyé
              CustomElevatedButton(
                text: "Envoyer",
                icon: cusFaIcon(
                  FontAwesomeIcons.solidPaperPlane,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
