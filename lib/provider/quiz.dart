import 'dart:io';
import 'package:aesd/models/quiz_model.dart';
import 'package:aesd/models/ranking.dart';
import 'package:aesd/requests/quiz_request.dart';
import 'package:flutter/material.dart';

class Quiz extends ChangeNotifier {
  final _request = QuizRequest();

  final List<QuizModel> _allQuizzes = [];
  List<QuizModel> get allQuizzes => _allQuizzes;
  QuizModel? _selectedQuiz;
  QuizModel? get selectedQuiz => _selectedQuiz;

  Future<void> getAll() async {
    final response = await _request.getAll();
    if (response.statusCode == 200) {
      print(response);
      _allQuizzes.clear();
      (response.data['data'] as List)
          .map((e) => _allQuizzes.add(QuizModel.fromJson(e)))
          .toList();
    } else {
      throw HttpException('Impossible de charger les quizzes');
    }
    notifyListeners();
  }

  Future getCorrectAnswers(int quizId) async {
    final response = await _request.correctAnswers(quizId);
    print(response);
    if (response.statusCode == 200) {
    } else {
      throw HttpException('Impossible de charger ce quiz');
    }
  }

  Future<void> getAny(int quizId) async {
    final response = await _request.getAny(quizId);
    if (response.statusCode == 200) {
      _selectedQuiz = QuizModel.fromJson(response.data['data']);
    } else {
      throw HttpException('Impossible de charger ce quiz');
    }
    notifyListeners();
  }

  Future sendResponses(
    int quizId, {
    required Map<String, List<int>> answers,
    required String timeElapsed,
  }) async {
    final response = await _request.sendResponses(
      quizId: quizId,
      results: {"reponses": answers, "time_remaining": timeElapsed},
    );
    print(response);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw HttpException("L'envoi des réponses a échoué");
    }
  }

  Future getMonthRanking() async {
    final response = await _request.monthRanking();
    if (response.statusCode == 200) {
      return (response.data['data'] as List)
          .map((element) => RankingModel.globalFromJson(element))
          .toList();
    } else {
      throw HttpException("Impossible d'obtenir le classement");
    }
  }

  Future getQuizRanking(int quizId) async {
    final response = await _request.quizRanking(quizId);
    if (response.statusCode == 200) {
      return (response.data['data'] as List)
          .map((element) => RankingModel.singleFromJson(element))
          .toList();
    } else {
      throw HttpException("Impossible d'obtenir le classement");
    }
  }
}
