import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/models/program.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DayProgramModel {
  bool isExtended = true;
  late String day;
  List<ProgramModel> program = [];

  DayProgramModel({required this.day, required this.program});

  Widget buildWidget(BuildContext context, {void Function()? reloader}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: notifire.getMainColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              if (reloader != null)
                InkWell(
                  radius: 100,
                  borderRadius: BorderRadius.circular(100),
                  overlayColor: WidgetStatePropertyAll(
                    notifire.getMaingey.withAlpha(100),
                  ),
                  onTap: () {
                    isExtended = !isExtended;
                    reloader();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: cusFaIcon(
                      isExtended
                          ? FontAwesomeIcons.chevronUp
                          : FontAwesomeIcons.chevronDown,
                      size: 15,
                    ),
                  ),
                ),
            ],
          ),
          if (isExtended)
            Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10),
              padding: EdgeInsets.all(5),
              width: double.infinity,
              decoration: BoxDecoration(
                color: notifire.getContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: notifire.getMaingey, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(program.length, (index) {
                  var current = program[index];
                  return current.getTile(context);
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget getWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 1.5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              day,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
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
          ),
        ],
      ),
    );
  }
}
