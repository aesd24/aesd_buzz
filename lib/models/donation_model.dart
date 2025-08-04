import 'package:intl/intl.dart';

class DonationModel {
  late int id;
  late String title;
  late String slug;
  late String description;
  late String date;
  late String churchName;
  late int objective;
  late int percent;

  DonationModel();

  DonationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
    objective = json['objective'];
    DateTime dateTime = DateTime.parse(json['end_at']);
    date = DateFormat('d MMM yyyy').format(dateTime);
    churchName = json['owner']['name'];
    percent = json['progress_in_percent'];
  }
}
