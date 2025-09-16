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
  List questions = [];

  QuizModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['intitule'];
    createdAt = DateTime.parse(json['created_at']);
    //expiryDate = DateTime.parse(json['expiryDate']);
    //description = json['description'];
    questions = json['questions'] ?? [];
    questionCount = json['questions_count'] ?? json['questions'].length;
  }
  
  GestureDetector toTile() => GestureDetector(
    onTap: () => Get.to(QuizMainPage(quiz: this)), //=> Get.to(QuizMainPage(quiz: this)),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold
          ),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$questionCount Questions"),
            Text(formatDate(createdAt, withTime: false))
          ],
        ),
      ),
    ),
  );
}
