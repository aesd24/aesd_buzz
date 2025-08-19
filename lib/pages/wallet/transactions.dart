import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/tiles.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomFormTextField(
                  label: "Recherche",
                  prefix: cusIcon(Icons.search),
              ),
              Column(
                children: List.generate(10, (index) {
                  return customTransactionTile(
                    context,
                    label: "Transaction $index",
                    amount: (index + 1) * 1000,
                    date: DateTime(2000 + index),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
