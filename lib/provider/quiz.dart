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
      // Garder hasPlayed si déjà marqué en local (au cas où l'API ne renvoie pas has_played)
      final alreadyPlayed = _allQuizzes.any((q) => q.id == quizId && q.hasPlayed);
      if (alreadyPlayed) _selectedQuiz!.hasPlayed = true;
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

  /// Marque un quiz comme déjà joué (après envoi des réponses).
  /// Met à jour la liste locale pour éviter de pouvoir rejouer avant le prochain getAll().
  void markQuizAsPlayed(int quizId, {int? score, String? timeRemaining}) {
    final index = _allQuizzes.indexWhere((q) => q.id == quizId);
    if (index >= 0) {
      _allQuizzes[index].hasPlayed = true;
      if (score != null) _allQuizzes[index].userScore = score;
      if (timeRemaining != null) _allQuizzes[index].userTimeRemaining = timeRemaining;
      notifyListeners();
    }
    if (_selectedQuiz?.id == quizId) {
      _selectedQuiz!.hasPlayed = true;
      if (score != null) _selectedQuiz!.userScore = score;
      if (timeRemaining != null) _selectedQuiz!.userTimeRemaining = timeRemaining;
      notifyListeners();
    }
  }
}
