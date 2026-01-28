import 'package:aesd/models/option_model.dart';

class QuestionModel {
  late int id;
  late String label;
  late int points;               // ✅ NOUVEAU: Points pour cette question
  late int repartitionPoints;    // ✅ NOUVEAU: Répartition des points (idem généralement)
  List<OptionModel> options = [];

  QuestionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['intitule'];
    points = json['points'] ?? 5;  // ✅ NOUVEAU: Défaut 5 points
    repartitionPoints = json['repartition_points'] ?? points;  // ✅ NOUVEAU
    final propositions = json['propositions_de_reponses'];
    propositions.map((e) => options.add(OptionModel.fromJson(e))).toList();
  }
}
