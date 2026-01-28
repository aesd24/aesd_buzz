# 🎯 Plan d'Implémentation - Points Quiz

## 📊 État Actuel vs État Cible

### ❌ État Actuel (Sans Points)

**GET /quiz** retourne:
```json
{
  "data": [
    {
      "id": 1,
      "theme": "Titre du quiz",
      "questions_count": 10,
      "has_played": false
      // ❌ PAS DE: total_points, points_per_question
    }
  ]
}
```

**POST /quiz/reponses/{id}** retourne:
```json
{
  "score": 75,
  "pourcentage": 85.5,
  "time_remaining": "00:15:30"
  // ❌ PAS DE: points détaillés par question
}
```

---

## ✅ État Cible (Avec Points)

### 1️⃣ **GET /quiz** - À MODIFIER

**Endpoint:** `GET /api/quiz`
**Action:** Ajouter les champs de points

```json
{
  "data": [
    {
      "id": 1,
      "theme": "Titre du quiz",
      "created_at": "2025-01-15T10:30:00Z",
      "date": "2025-01-20T23:59:59Z",
      "questions_count": 10,
      "total_points": 50,              // ✅ NOUVEAU: Points totaux possibles
      "points_per_question": 5,         // ✅ NOUVEAU: Points par bonne réponse
      "has_played": false,
      "user_score": 40,                 // ✅ À AJOUTER: Score de l'utilisateur s'il l'a joué
      "user_quiz": {
        "score": 40,
        "percentage": 80,
        "time_remaining": "00:05:30"
      }
    }
  ]
}
```

### 2️⃣ **GET /quiz/{id}** - À MODIFIER

**Endpoint:** `GET /api/quiz/{id}`
**Action:** Ajouter les points dans les questions

```json
{
  "data": {
    "id": 1,
    "theme": "Titre du quiz",
    "total_points": 50,                // ✅ NOUVEAU
    "points_per_question": 5,          // ✅ NOUVEAU
    "created_at": "2025-01-15T10:30:00Z",
    "date": "2025-01-20T23:59:59Z",
    "questions": [
      {
        "id": 1,
        "question": "Texte de la question",
        "points": 5,                   // ✅ NOUVEAU: Points pour cette question
        "options": [
          {
            "id": 1,
            "option": "Réponse 1"
          },
          {
            "id": 2,
            "option": "Réponse 2"
          }
        ]
      }
    ],
    "questions_count": 10,
    "has_played": false
  }
}
```

### 3️⃣ **POST /quiz/reponses/{id}** - À MODIFIER

**Endpoint:** `POST /api/quiz/reponses/{id}`
**Action:** Retourner les points détaillés et le score final

**Request (inchangé):**
```json
{
  "reponses": {
    "1": [1, 2],
    "2": [3],
    "3": [5, 6]
  },
  "time_remaining": "00:15:30"
}
```

**Response (MODIFIÉE):**
```json
{
  "score": 80,                        // Score final (avec facteur temps appliqué)
  "pourcentage": 80,                  // Pourcentage de réussite
  "time_remaining": "00:15:30",       // Temps restant
  "total_points": 50,                 // ✅ NOUVEAU: Points totaux possibles
  "points_earned": 40,                // ✅ NOUVEAU: Points totaux gagnés
  "time_factor": 1.0,                 // ✅ NOUVEAU: Facteur temps appliqué
  "correct_count": 8,                 // ✅ NOUVEAU: Nombre de réponses correctes
  "wrong_count": 2,                   // ✅ NOUVEAU: Nombre de réponses incorrectes
  "questions": [                      // ✅ NOUVEAU: Détail par question
    {
      "question_id": 1,
      "question_text": "Texte de la question",
      "user_answers": [1, 2],
      "correct_answers": [1, 2],
      "is_correct": true,
      "points_possible": 5,
      "points_earned": 5
    },
    {
      "question_id": 2,
      "question_text": "Autre question",
      "user_answers": [3],
      "correct_answers": [3],
      "is_correct": true,
      "points_possible": 5,
      "points_earned": 5
    },
    {
      "question_id": 3,
      "question_text": "Troisième question",
      "user_answers": [5],
      "correct_answers": [5, 6],
      "is_correct": false,
      "points_possible": 5,
      "points_earned": 0
    }
  ]
}
```

---

## 🔧 Implémentation Backend (Laravel)

### Migration: Ajouter colonne points aux tables

```sql
-- Ajouter colonnes à la table questions
ALTER TABLE questions ADD COLUMN points INT DEFAULT 5;

-- Ajouter colonnes à la table user_quizzes
ALTER TABLE user_quizzes ADD COLUMN points_earned INT DEFAULT 0;
ALTER TABLE user_quizzes ADD COLUMN total_points INT DEFAULT 0;
```

### Modifier QuizController.php

#### 1. Méthode `index()` - GET /quiz

```php
public function index()
{
    $user = auth()->user();
    $quizzes = Quiz::where('status', 'published')
        ->whereDate('expires_at', '>=', now())
        ->with(['questions', 'questions.options'])
        ->get()
        ->map(function($quiz) use ($user) {
            // Calculer les points totaux
            $totalPoints = $quiz->questions->sum('points');
            
            // Vérifier si l'utilisateur a joué
            $userQuiz = UserQuiz::where('user_id', $user->id)
                ->where('quiz_id', $quiz->id)
                ->whereYear('created_at', now()->year)
                ->whereMonth('created_at', now()->month)
                ->first();
            
            return [
                'id' => $quiz->id,
                'theme' => $quiz->title,
                'created_at' => $quiz->created_at->toIso8601String(),
                'date' => $quiz->expires_at->toIso8601String(),
                'questions_count' => $quiz->questions->count(),
                'total_points' => $totalPoints,           // ✅ NOUVEAU
                'points_per_question' => $totalPoints / max(1, $quiz->questions->count()),  // ✅ NOUVEAU
                'has_played' => $userQuiz ? true : false,
                'user_score' => $userQuiz?->score,
                'user_quiz' => $userQuiz ? [
                    'score' => $userQuiz->score,
                    'percentage' => $userQuiz->percentage,
                    'time_remaining' => $userQuiz->time_remaining
                ] : null
            ];
        });
    
    return response()->json(['data' => $quizzes]);
}
```

#### 2. Méthode `show()` - GET /quiz/{id}

```php
public function show($quizId)
{
    $user = auth()->user();
    $quiz = Quiz::with(['questions', 'questions.options'])->find($quizId);
    
    if (!$quiz) {
        return response()->json(['error' => 'Quiz not found'], 404);
    }
    
    // Vérifier si l'utilisateur a déjà joué ce mois
    $hasPlayedThisMonth = UserQuiz::where('user_id', $user->id)
        ->where('quiz_id', $quizId)
        ->whereYear('created_at', now()->year)
        ->whereMonth('created_at', now()->month)
        ->exists();
    
    if ($hasPlayedThisMonth) {
        return response()->json(['error' => 'Vous avez déjà joué ce quiz ce mois-ci'], 403);
    }
    
    $totalPoints = $quiz->questions->sum('points');
    
    return response()->json([
        'data' => [
            'id' => $quiz->id,
            'theme' => $quiz->title,
            'created_at' => $quiz->created_at->toIso8601String(),
            'date' => $quiz->expires_at->toIso8601String(),
            'total_points' => $totalPoints,              // ✅ NOUVEAU
            'points_per_question' => $quiz->questions->count() > 0 
                ? $totalPoints / $quiz->questions->count() 
                : 0,                                      // ✅ NOUVEAU
            'questions' => $quiz->questions->map(fn($q) => [
                'id' => $q->id,
                'question' => $q->text,
                'points' => $q->points,                  // ✅ NOUVEAU
                'options' => $q->options->map(fn($o) => [
                    'id' => $o->id,
                    'option' => $o->text
                ])
            ]),
            'questions_count' => $quiz->questions->count(),
            'has_played' => false
        ]
    ]);
}
```

#### 3. Méthode `submitAnswers()` - POST /quiz/reponses/{id}

```php
public function submitAnswers($quizId, Request $request)
{
    $user = auth()->user();
    
    // Vérifier doublon
    $alreadyPlayed = UserQuiz::where('user_id', $user->id)
        ->where('quiz_id', $quizId)
        ->whereYear('created_at', now()->year)
        ->whereMonth('created_at', now()->month)
        ->exists();
    
    if ($alreadyPlayed) {
        return response()->json(['error' => 'Rejeu détecté'], 403);
    }
    
    $quiz = Quiz::with('questions.options')->find($quizId);
    $answers = $request->input('reponses', []);
    $timeRemaining = $request->input('time_remaining', '00:00:00');
    
    // Calculer les réponses correctes et points
    $correctCount = 0;
    $totalPoints = 0;
    $pointsEarned = 0;
    $questionsDetail = [];
    
    foreach ($answers as $questionId => $userAnswers) {
        $question = $quiz->questions->find($questionId);
        if (!$question) continue;
        
        $correctOptions = $question->options()
            ->where('is_correct', true)
            ->pluck('id')
            ->toArray();
        
        $isCorrect = array_diff($userAnswers, $correctOptions) === 
                    array_diff($correctOptions, $userAnswers);
        
        if ($isCorrect) {
            $correctCount++;
            $pointsEarned += $question->points;
        }
        
        $totalPoints += $question->points;
        
        // Détail par question
        $questionsDetail[] = [
            'question_id' => $question->id,
            'question_text' => $question->text,
            'user_answers' => $userAnswers,
            'correct_answers' => $correctOptions,
            'is_correct' => $isCorrect,
            'points_possible' => $question->points,
            'points_earned' => $isCorrect ? $question->points : 0
        ];
    }
    
    // Calculer le facteur temps
    $timeParts = explode(':', $timeRemaining);
    $totalSeconds = (int)$timeParts[0] * 3600 + (int)$timeParts[1] * 60 + (int)$timeParts[2];
    $estimatedSeconds = count($quiz->questions) * 30; // 30s par question
    $timeElapsed = max(1, $estimatedSeconds - $totalSeconds);
    $timeFactor = max(0.5, min(1.5, $estimatedSeconds / $timeElapsed));
    
    // Score final avec facteur temps
    $baseScore = ($pointsEarned / max(1, $totalPoints)) * 100;
    $finalScore = (int)($baseScore * $timeFactor);
    
    // Sauvegarder en DB
    $userQuiz = UserQuiz::create([
        'user_id' => $user->id,
        'quiz_id' => $quizId,
        'score' => $finalScore,
        'percentage' => ($correctCount / count($quiz->questions)) * 100,
        'time_remaining' => $timeRemaining,
        'points_earned' => $pointsEarned,           // ✅ NOUVEAU
        'total_points' => $totalPoints,             // ✅ NOUVEAU
        'correct_answers' => $correctCount,
        'total_questions' => count($quiz->questions)
    ]);
    
    // Réponse avec détails
    return response()->json([
        'score' => $finalScore,
        'pourcentage' => ($correctCount / count($quiz->questions)) * 100,
        'time_remaining' => $timeRemaining,
        'total_points' => $totalPoints,             // ✅ NOUVEAU
        'points_earned' => $pointsEarned,           // ✅ NOUVEAU
        'time_factor' => $timeFactor,               // ✅ NOUVEAU
        'correct_count' => $correctCount,           // ✅ NOUVEAU
        'wrong_count' => count($quiz->questions) - $correctCount,  // ✅ NOUVEAU
        'questions' => $questionsDetail             // ✅ NOUVEAU
    ], 201);
}
```

---

## 🔄 Implémentation Frontend (Flutter)

### 1. Mettre à jour QuizModel

```dart
// lib/models/quiz_model.dart

class QuizModel {
  late int id;
  late String title;
  late DateTime createdAt;
  late DateTime expiryDate;
  late int questionCount;
  bool isAvailable = false;
  late bool hasPlayed;
  int? userScore;
  String? userTimeRemaining;
  
  // ✅ NOUVEAU: Champs de points
  late int totalPoints;              // Points totaux du quiz
  late double pointsPerQuestion;     // Points par question
  int? userPoints;                   // Points de l'utilisateur s'il l'a joué
  
  List questions = [];

  QuizModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['theme'];
    createdAt = DateTime.parse(json['created_at']);
    expiryDate = DateTime.parse(json['date']).add(Duration(days: 1));
    questions = json['questions'] ?? [];
    hasPlayed = json['has_played'] ?? false;
    questionCount = json['questions_count'] ?? questions.length;
    isAvailable = DateTime.now().isBefore(expiryDate);
    
    // Points
    totalPoints = json['total_points'] ?? 50;           // ✅ NOUVEAU
    pointsPerQuestion = (json['points_per_question'] ?? 5.0).toDouble();  // ✅ NOUVEAU
    userPoints = json['user_score'];                     // ✅ NOUVEAU
    
    // Stats utilisateur
    if (json['user_quiz'] != null) {
      userScore = int.tryParse(json['user_quiz']['score']?.toString() ?? '0');
      userTimeRemaining = json['user_quiz']['time_remaining'];
    }
  }
}
```

### 2. Mettre à jour QuizResultModel

```dart
// Nouveau modèle pour les résultats détaillés

class QuizResultModel {
  late int score;
  late double pourcentage;
  late String timeRemaining;
  late int totalPoints;              // ✅ NOUVEAU
  late int pointsEarned;             // ✅ NOUVEAU
  late double timeFactor;            // ✅ NOUVEAU
  late int correctCount;             // ✅ NOUVEAU
  late int wrongCount;               // ✅ NOUVEAU
  late List<QuestionResult> questions; // ✅ NOUVEAU

  QuizResultModel.fromJson(Map<String, dynamic> json) {
    score = json['score'] ?? 0;
    pourcentage = (json['pourcentage'] ?? 0).toDouble();
    timeRemaining = json['time_remaining'] ?? '00:00:00';
    totalPoints = json['total_points'] ?? 0;           // ✅ NOUVEAU
    pointsEarned = json['points_earned'] ?? 0;        // ✅ NOUVEAU
    timeFactor = (json['time_factor'] ?? 1.0).toDouble();  // ✅ NOUVEAU
    correctCount = json['correct_count'] ?? 0;        // ✅ NOUVEAU
    wrongCount = json['wrong_count'] ?? 0;            // ✅ NOUVEAU
    
    questions = (json['questions'] as List?)
        ?.map((q) => QuestionResult.fromJson(q))
        .toList() ?? [];                               // ✅ NOUVEAU
  }
}

class QuestionResult {
  late int questionId;
  late String questionText;
  late List<int> userAnswers;
  late List<int> correctAnswers;
  late bool isCorrect;
  late int pointsPossible;
  late int pointsEarned;

  QuestionResult.fromJson(Map<String, dynamic> json) {
    questionId = json['question_id'] ?? 0;
    questionText = json['question_text'] ?? '';
    userAnswers = List<int>.from(json['user_answers'] ?? []);
    correctAnswers = List<int>.from(json['correct_answers'] ?? []);
    isCorrect = json['is_correct'] ?? false;
    pointsPossible = json['points_possible'] ?? 0;
    pointsEarned = json['points_earned'] ?? 0;
  }
}
```

### 3. Affichage des Points dans l'UI

**Dans QuizHome - Afficher les points du quiz:**

```dart
// lib/pages/quiz/home.dart

Text(
  'Points: ${quiz.totalPoints}',  // ✅ AFFICHE LES POINTS
  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
),
```

**Dans QuizResultPage - Afficher le détail des points:**

```dart
// lib/pages/quiz/result.dart

// Afficher points gagnés
Text(
  '${resultData.pointsEarned} / ${resultData.totalPoints} points',  // ✅ NOUVEAU
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),

// Afficher facteur temps
Text(
  'Facteur temps: ${resultData.timeFactor.toStringAsFixed(2)}x',  // ✅ NOUVEAU
  style: TextStyle(fontSize: 14, color: Colors.blue),
),

// Afficher détail par question
ListView.builder(
  itemCount: resultData.questions.length,
  itemBuilder: (context, index) {
    final q = resultData.questions[index];
    return ListTile(
      title: Text(q.questionText),
      subtitle: Text('${q.pointsEarned} / ${q.pointsPossible} points'),  // ✅ NOUVEAU
      trailing: Icon(
        q.isCorrect ? Icons.check_circle : Icons.cancel,
        color: q.isCorrect ? Colors.green : Colors.red,
      ),
    );
  },
)
```

---

## ✅ Checklist Implémentation

### Backend (Laravel)
- [ ] Migration: Ajouter colonnes `points` à `questions`
- [ ] Migration: Ajouter colonnes `points_earned`, `total_points` à `user_quizzes`
- [ ] Modifier `QuizController@index()` - Ajouter total_points, points_per_question
- [ ] Modifier `QuizController@show()` - Ajouter points dans questions
- [ ] Modifier `QuizController@submitAnswers()` - Retourner points détaillés
- [ ] Tester avec Swagger/Postman

### Frontend (Flutter)
- [ ] Mettre à jour `QuizModel` - Ajouter totalPoints, pointsPerQuestion
- [ ] Créer `QuizResultModel` avec détails des questions
- [ ] Mettre à jour `QuizResultPage` - Afficher points
- [ ] Mettre à jour `QuizHome` - Afficher points du quiz
- [ ] Afficher détail par question dans correction
- [ ] Afficher facteur temps appliqué
- [ ] Tests UI

---

## 🚀 Ordre d'Implémentation

1. **Backend**: Migrations + QuizController modifications (30 min)
2. **Backend**: Tests API avec Swagger (10 min)
3. **Frontend**: Mettre à jour modèles (15 min)
4. **Frontend**: Affichage UI (30 min)
5. **Tests**: Bout en bout (30 min)

**Total: ~2 heures**

