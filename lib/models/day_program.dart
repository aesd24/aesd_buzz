import 'package:aesd/models/program.dart';
import 'package:flutter/material.dart';

class DayProgramModel {
  late String day;
  List<ProgramModel> program = [];

  DayProgramModel.fromJson(json) {
    day = json['day'];
    json['program'].forEach((current) {
      //print(current);
      program.add(ProgramModel.fromJson(current));
    });
  }

  getWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 1.5),
          borderRadius: BorderRadius.circular(7)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(day,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold)),
          ),
          Column(
            children: List.generate(program.length, (index) {
              var current = program[index];
              return Column(
                children: [
                  current.getTile(context),
                  if (index != 2) const Divider(),
                ],
              );
            }),
          )
        ],
      ),
    );
  }
}
