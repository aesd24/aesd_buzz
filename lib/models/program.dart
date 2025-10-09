import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

TimeOfDay parseTime(String timeString) {
  try {
    // Sépare la chaîne "HH:mm:ss" en parties
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    // La troisième partie (secondes) est ignorée car TimeOfDay ne la stocke pas
    return TimeOfDay(hour: hour, minute: minute);
  } catch (e) {
    // Si l'analyse échoue (format invalide, etc.), retourne une valeur par défaut
    // pour éviter que l'application ne plante. Ici, minuit.
    print('Erreur lors de l\'analyse de l\'heure "$timeString": $e');
    return const TimeOfDay(hour: 0, minute: 0);
  }
}

class ProgramModel {
  late int id;
  late String title;
  late String day;
  late String description;
  String? image;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late DateTime date;

  ProgramModel.fromJson(Map<String, dynamic> json) {
    id = json['programme_id'];
    title = json['title'];
    day = json['day'];
    description = json["description"];
    image = json['file'];
    startTime = parseTime(json['start_time']);
    endTime = parseTime(json['end_time']);
    date = DateTime.parse(json['created_at']);
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
