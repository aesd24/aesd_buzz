import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
import 'package:flutter/material.dart';

class WithDrawingPage extends StatefulWidget {
  const WithDrawingPage({super.key});

  @override
  State<WithDrawingPage> createState() => _WithDrawingPageState();
}

class _WithDrawingPageState extends State<WithDrawingPage> {
  // controller
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Retirer de l'argent"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Image.asset(
                "assets/icons/give.png",
                height: 100,
              ),
            ),
            CustomFormTextField(
                label: "Montant",
                type: TextInputType.number,
                controller: amountController),
            CustomElevatedButton(text: "Valider", onPressed: () {})
          ],
        ),
      ),
    );
  }
}
