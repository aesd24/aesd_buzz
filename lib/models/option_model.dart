import 'package:flutter/material.dart';

class OptionModel {
  late int id;
  late String label;

  OptionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['intitule'];
  }

  Widget toTile({
    required String title,
    required void Function(dynamic) onChange,
    required dynamic value,
    required List groupValue
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: groupValue.contains(value) ? Colors.green.shade100 : null,
      ),
      child: ListTile(
        onTap: () => onChange(value),
        title: Text(title),
      ),
    );
  }
}
