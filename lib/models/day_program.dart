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

  Widget buildWidget(
    BuildContext context, {
    void Function()? reloader,
    void Function(String)? onDeleteDay,
    void Function(int)? onDeleteProgram,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 5,
                margin: EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: notifire.info
                ),
              ),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        day,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (reloader != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (onDeleteDay != null)
                              IconButton(
                                onPressed: () => onDeleteDay(day),
                                icon: cusFaIcon(
                                  FontAwesomeIcons.trashCan,
                                  color: notifire.danger,
                                ),
                              ),

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
                        border: Border.all(
                          color: notifire.getMaingey,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(program.length, (index) {
                          var current = program[index];
                          return current.getTile(
                            context,
                            onDelete:
                                onDeleteProgram != null
                                    ? () => onDeleteProgram(current.id)
                                    : null,
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
