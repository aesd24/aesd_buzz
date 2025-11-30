import 'package:aesd/appstaticdata/staticdata.dart';
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
    required int value,
    required List groupValue,
  }) {
    return GestureDetector(
      onTap: () => onChange(value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        margin: EdgeInsets.symmetric(vertical: 7),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              groupValue.contains(value)
                  ? notifire.getMainColor.withAlpha(30)
                  : notifire.getContainer,
          border: Border.all(
            color:
                groupValue.contains(value)
                    ? notifire.getMainColor
                    : notifire.getMaingey,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  groupValue.contains(value)
                      ? notifire.getMainColor.withAlpha(30)
                      : notifire.getMaingey.withAlpha(75),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Checkbox(
              side: BorderSide(
                color:
                    groupValue.contains(value)
                        ? notifire.getMainColor
                        : notifire.getMaingey,
                width: 2,
              ),
              shape: CircleBorder(),
              value: groupValue.contains(value),
              onChanged: (v) => onChange(value),
            ),
            SizedBox(width: 5),
            Text(title),
          ],
        ),
      ),
    );
  }
}
