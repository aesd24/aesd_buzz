import 'dart:io';
import 'package:aesd/models/quiz_model.dart';
import 'package:aesd/requests/quiz_request.dart';
import 'package:flutter/material.dart';

class Quiz extends ChangeNotifier {
  final _request = QuizRequest();

  final List<QuizModel> _allQuizzes = [];
  List<QuizModel> get allQuizzes => _allQuizzes;
  QuizModel? _selectedQuiz;
  QuizModel? get selectedQuiz => _selectedQuiz;

  getAll() async {
    final response = await _request.getAll();
    if (response.statusCode == 200) {
      _allQuizzes.clear();
      List quizzes = response.data;
      quizzes.map((e) => _allQuizzes.add(QuizModel.fromJson(e))).toList();
      print(_allQuizzes);
    } else {
      throw HttpException('Impossible de charger les quizzes');
    }
    notifyListeners();
  }

  getAny(int quizId) async {
    final response = await _request.getAny(quizId);
    if (response.statusCode == 200) {
      print(response.data);
      _selectedQuiz = QuizModel.fromJson(response.data['data']);
    } else {
      throw HttpException('Impossible de charger ce quiz');
    }
    notifyListeners();
  }

  sendResponses(int quizId, {
    required Map<String, List<int>> answers,
    required String timeElapsed
  }) async {
    final response = await _request.sendResponses(
      quizId: quizId,
      results: {
        "reponses": answers,
        "time_remaining": timeElapsed
      }
    );
    print(response);
    if (response.statusCode == 200) {
      //print(response.data);
    } else {
      throw HttpException("L'envoi des réponses a échoué");
    }
  }
}