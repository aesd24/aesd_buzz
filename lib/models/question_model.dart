import 'package:aesd/models/option_model.dart';

class QuestionModel {
  late int id;
  late String label;
  List<OptionModel> options = [];

  QuestionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['intitule'];
    final propositions = json['propositions_de_reponses'];
    propositions.map((e) => options.add(OptionModel.fromJson(e))).toList();
  }
}
