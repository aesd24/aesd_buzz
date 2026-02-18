/// Modèle pour les résultats détaillés d'un quiz après soumission

class QuizResultModel {
  late int score;                    // Score final avec facteur temps
  late double pourcentage;           // Pourcentage de réussite
  late String timeRemaining;         // Temps restant au format HH:mm:ss
  late int totalPoints;              // ✅ Points totaux possibles
  late int pointsEarned;             // ✅ Points gagnés
  late double timeFactor;            // ✅ Facteur temps appliqué (0.5 à 1.5)
  late int correctCount;             // ✅ Nombre de réponses correctes
  late int wrongCount;               // ✅ Nombre de réponses incorrectes
  List<QuestionResultDetail> questions = [];  // ✅ Détail par question

  QuizResultModel.fromJson(Map<String, dynamic> json) {
    score = json['score'] ?? 0;
    pourcentage = (json['pourcentage'] ?? json['percentage'] ?? 0).toDouble();
    timeRemaining = json['time_remaining'] ?? '00:00:00';
    
    // Parser le détail par question si disponible
    if (json['questions'] != null) {
      questions = (json['questions'] as List)
          .map((q) => QuestionResultDetail.fromJson(q))
          .toList();
    }

    // ✅ Champs de points - avec fallbacks
    totalPoints = json['total_points'] ?? 
                 json['points_maximal'] ?? 
                 0;
    
    pointsEarned = json['points_earned'] ?? 
                  json['user_points'] ?? 
                  0;
    
    // Fallback: Si pointsEarned est 0 mais on a un score, utiliser le score (si pas de points bonus séparés)
    if (pointsEarned == 0 && score > 0 && totalPoints > 0) {
      pointsEarned = score > totalPoints ? totalPoints : score;
    }

    timeFactor = (json['time_factor'] ?? 1.0).toDouble();
    
    // ✅ Calcul robuste des compteurs
    if (questions.isNotEmpty) {
      // Priorité 1: Calculer depuis les questions retournées
      correctCount = questions.where((q) => q.isCorrect).length;
      wrongCount = questions.where((q) => !q.isCorrect).length;
    } else {
      // Priorité 2: Utiliser les champs JSON
      int totalQs = json['total_questions'] ?? 0;
      
      correctCount = json['correct_count'] ?? 
                    json['correct_answers_count'] ??
                    ((pourcentage / 100 * (totalQs > 0 ? totalQs : 1)).toInt());
                    
      wrongCount = json['wrong_count'] ?? 
                  json['wrong_answers_count'] ?? 
                  (totalQs - correctCount);
                  
      // Sécurité: Pas de négatifs
      if (wrongCount < 0) wrongCount = 0;
      if (correctCount < 0) correctCount = 0;
    }
  }

  /// Calculer le nombre total de questions
  int get totalQuestions => correctCount + wrongCount;

  /// Vérifier si toutes les réponses sont correctes (100%)
  bool get isPerfect => wrongCount == 0 && totalQuestions > 0;

  /// Obtenir un message de félicitations basé sur la performance
  String getPerformanceMessage() {
    if (pourcentage >= 90) return '🎉 Excellent !';
    if (pourcentage >= 75) return '👍 Très bien !';
    if (pourcentage >= 60) return '✓ Pas mal !';
    if (pourcentage >= 50) return '📚 Continuez !';
    return '💪 Travail en cours';
  }
}

/// Détail du résultat pour une question spécifique
class QuestionResultDetail {
  late int questionId;
  late String questionText;
  late List<int> userAnswers;        // IDs des réponses de l'utilisateur
  late List<int> correctAnswers;     // IDs des bonnes réponses
  late bool isCorrect;               // Si la question est correctement répondue
  late int pointsPossible;           // Points maximaux pour cette question
  late int pointsEarned;             // Points gagnés (0 ou pointsPossible)

  QuestionResultDetail.fromJson(Map<String, dynamic> json) {
    questionId = json['question_id'] ?? 0;
    questionText = json['question_text'] ?? '';
    userAnswers = List<int>.from(json['user_answers'] ?? []);
    correctAnswers = List<int>.from(json['correct_answers'] ?? []);
    isCorrect = json['is_correct'] ?? false;
    pointsPossible = json['points_possible'] ?? 0;
    pointsEarned = json['points_earned'] ?? 0;
  }

  /// Indique si c'est une réponse correcte (utility)
  bool get wasAnsweredCorrectly => isCorrect;

  /// Retourner un emoji basé sur le résultat
  String getResultEmoji() {
    if (isCorrect) return '✓';
    return '✗';
  }

  /// Obtenir la couleur du résultat
  int getResultColor() {
    // Vert: 0xFF4CAF50, Rouge: 0xFFF44336
    return isCorrect ? 0xFF4CAF50 : 0xFFF44336;
  }
}
