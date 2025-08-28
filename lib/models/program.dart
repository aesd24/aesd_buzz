import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProgramModel {
  late String title;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late String place;

  ProgramModel.fromJson(json) {
    title = json['title'];

    var parts = json["startTime"].split(":");
    startTime =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    parts = json["startTime"].split(":");
    endTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    place = json['place'];
  }

  Widget getTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "${startTime.hour}:${startTime.minute} - ${endTime.hour}:${endTime.minute}"),
              Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.locationPin,
                    size: 15,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(place),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.labelLarge)
        ],
      ),
    );
  }
}
