import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/pages/quiz/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizModel {
  late int id;
  late String title;
  late String description;
  late DateTime createdAt;
  late DateTime expiryDate;
  late int questionCount;
  bool isAvailable = false;
  late bool hasPlayed;
  List questions = [];

  QuizModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['intitule'];
    createdAt = DateTime.parse(json['created_at']);
    expiryDate = DateTime.parse(json['date']);
    //description = json['description'];
    questions = json['questions'] ?? [];
    hasPlayed = json['has_played'] ?? false;
    questionCount = json['questions_count'] ?? json['questions'].length;
    isAvailable = DateTime.now().isBefore(expiryDate);
  }

  GestureDetector toTile() => GestureDetector(
    onTap: () {
      if (!hasPlayed) {
        Get.to(QuizMainPage(quiz: this));
      }
    }, //=> Get.to(QuizMainPage(quiz: this)),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: hasPlayed ? notifire.getMaingey.withAlpha(75) : notifire.getContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: hasPlayed ? null : [
          BoxShadow(
            color: notifire.getMaingey.withAlpha(100),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$questionCount Questions"),
            Text(formatDate(createdAt, withTime: false)),
          ],
        ),
      ),
    ),
  );
}
