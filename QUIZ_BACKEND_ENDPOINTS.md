# 🎯 Endpoints Quiz - Analyse et Requirements Backend

## 📋 Endpoints Actuels (Déjà Implémentés)

### Base Route
```
Base URL: https://monapi.eglisesetserviteursdedieu.com/api/
Base Route: quiz
```

---

### 1. **GET /quiz** ✅
**Description:** Récupère la liste de tous les quiz disponibles

**Méthode:** `GET`  
**Endpoint:** `/quiz`

**Réponse attendue:**
```json
{
  "data": [
    {
      "id": 1,
      "theme": "Titre du quiz",
      "created_at": "2025-01-15T10:30:00Z",
      "date": "2025-01-20T23:59:59Z",  // Date d'expiration
      "questions": [...],  // Liste des questions (optionnel dans la liste)
      "questions_count": 20,  // Nombre de questions
      "has_played": false  // Si l'utilisateur a déjà joué
    }
  ]
}
```

**Utilisé dans:** `QuizProvider.getAll()`, `QuizHome`

---

### 2. **GET /quiz/{quizId}** ✅
**Description:** Récupère les détails d'un quiz spécifique avec toutes ses questions

**Méthode:** `GET`  
**Endpoint:** `/quiz/{quizId}`

**Réponse attendue:**
```json
{
  "data": {
    "id": 1,
    "theme": "Titre du quiz",
    "created_at": "2025-01-15T10:30:00Z",
    "date": "2025-01-20T23:59:59Z",
    "questions": [
      {
        "id": 1,
        "question": "Texte de la question",
        "options": [
          {"id": 1, "option": "Réponse 1"},
          {"id": 2, "option": "Réponse 2"},
          {"id": 3, "option": "Réponse 3"},
          {"id": 4, "option": "Réponse 4"}
        ]
      }
    ],
    "questions_count": 20,
    "has_played": false
  }
}
```

**Utilisé dans:** `QuizProvider.getAny()`, `QuizMainPage`

---

### 3. **POST /quiz/reponses/{quizId}** ✅
**Description:** Envoie les réponses d'un utilisateur pour un quiz

**Méthode:** `POST`  
**Endpoint:** `/quiz/reponses/{quizId}`

**Body:**
```json
{
  "reponses": {
    "1": [1, 2],  // question_id: [option_ids sélectionnés]
    "2": [3],
    "3": [5, 6]
  },
  "time_remaining": "00:15:30"  // Temps restant au format HH:mm:ss
}
```

**Réponse attendue:**
```json
{
  "score": 75,  // Score obtenu
  "time_remaining": "00:15:30",  // Temps utilisé
  "pourcentage": 85.5  // Taux de réussite en pourcentage
}
```

**Utilisé dans:** `QuizProvider.sendResponses()`, `QuizResultPage`

---

### 4. **GET /quiz/{quizId}/bonnes-reponses** ✅
**Description:** Récupère les bonnes réponses d'un quiz (pour la correction)

**Méthode:** `GET`  
**Endpoint:** `/quiz/{quizId}/bonnes-reponses`

**Réponse attendue:**
```json
{
  "data": [
    {
      "question_id": 1,
      "correct_options": [1, 2]  // IDs des bonnes réponses
    }
  ]
}
```

**Utilisé dans:** `QuizProvider.getCorrectAnswers()`, `QuizCorrectResponses`

---

### 5. **GET /quiz/classement-general-mensuel** ✅
**Description:** Récupère le classement mensuel général de tous les utilisateurs

**Méthode:** `GET`  
**Endpoint:** `/quiz/classement-general-mensuel`

**Réponse attendue:**
```json
{
  "data": [
    {
      "user_id": 1,
      "name": "Nom de l'utilisateur",
      "profile_photo_url": "https://...",
      "rang": 1,  // Position dans le classement
      "total_score": "1500"  // Score total mensuel
    }
  ]
}
```

**Utilisé dans:** `QuizProvider.getMonthRanking()`, `QuizRankingPage` (classement mensuel)

---

### 6. **GET /quiz/{quizId}/classement** ✅
**Description:** Récupère le classement spécifique d'un quiz

**Méthode:** `GET`  
**Endpoint:** `/quiz/{quizId}/classement`

**Réponse attendue:**
```json
{
  "data": [
    {
      "user_id": 1,
      "name": "Nom de l'utilisateur",
      "profile_photo_url": "https://...",
      "rang": 1,
      "score": "85",  // Score pour ce quiz spécifique
      "time_remaining": "00:12:30"  // Temps utilisé
    }
  ]
}
```

**Utilisé dans:** `QuizProvider.getQuizRanking()`, `QuizRankingPage` (classement par quiz)

---

## ❌ Endpoints Manquants (À Ajouter)

### 1. **GET /quiz/user/stats** 🔴 PRIORITÉ HAUTE
**Description:** Récupère les statistiques personnelles de l'utilisateur connecté

**Méthode:** `GET`  
**Endpoint:** `/quiz/user/stats`

**Réponse attendue:**
```json
{
  "total_score": 1850,  // Score total cumulé
  "global_rank": 12,  // Rang dans le classement mensuel
  "quizzes_completed": 8,  // Nombre de quiz complétés
  "quizzes_available": 15,  // Nombre de quiz disponibles
  "average_score": 85.5,  // Score moyen
  "best_score": 95,  // Meilleur score
  "total_time_spent": "02:30:45"  // Temps total passé sur les quiz
}
```

**Utilisé dans:** `QuizHome._buildStatsCards()` - Actuellement les valeurs sont hardcodées :
- Score Total : `'1,850'` (hardcodé)
- Rang : `'#12'` (hardcodé)

**Impact:** Les cartes de statistiques dans la page d'accueil des quiz affichent des données fictives.

---

### 2. **GET /quiz/user/history** 🟡 PRIORITÉ MOYENNE
**Description:** Récupère l'historique des quiz joués par l'utilisateur

**Méthode:** `GET`  
**Endpoint:** `/quiz/user/history`

**Query Parameters (optionnels):**
- `page` : Numéro de page pour pagination
- `limit` : Nombre d'éléments par page

**Réponse attendue:**
```json
{
  "data": [
    {
      "quiz_id": 1,
      "quiz_title": "Titre du quiz",
      "score": 85,
      "percentage": 85.5,
      "time_used": "00:15:30",
      "played_at": "2025-01-15T10:30:00Z",
      "rank": 5  // Rang dans ce quiz
    }
  ],
  "current_page": 1,
  "total_pages": 3,
  "total": 25
}
```

**Utilisé dans:** Page d'historique (à créer) ou pour afficher les quiz déjà joués avec plus de détails.

---

### 3. **GET /quiz/user/result/{quizId}** 🟡 PRIORITÉ MOYENNE
**Description:** Récupère le résultat détaillé d'un quiz spécifique joué par l'utilisateur

**Méthode:** `GET`  
**Endpoint:** `/quiz/user/result/{quizId}`

**Réponse attendue:**
```json
{
  "quiz_id": 1,
  "quiz_title": "Titre du quiz",
  "score": 85,
  "total_points": 100,
  "percentage": 85.5,
  "time_used": "00:15:30",
  "time_limit": "00:20:00",
  "played_at": "2025-01-15T10:30:00Z",
  "rank": 5,
  "total_players": 150,
  "correct_answers": 17,
  "wrong_answers": 3,
  "questions": [
    {
      "question_id": 1,
      "question": "Texte de la question",
      "user_answers": [1, 2],  // Réponses de l'utilisateur
      "correct_answers": [1, 2],  // Bonnes réponses
      "is_correct": true,
      "points_earned": 5
    }
  ]
}
```

**Utilisé dans:** Page de détails d'un résultat de quiz (pour revoir les réponses).

---

### 4. **GET /quiz/{quizId}/stats** 🟢 PRIORITÉ BASSE
**Description:** Récupère les statistiques globales d'un quiz (nombre de joueurs, score moyen, etc.)

**Méthode:** `GET`  
**Endpoint:** `/quiz/{quizId}/stats`

**Réponse attendue:**
```json
{
  "quiz_id": 1,
  "total_players": 150,
  "average_score": 75.5,
  "average_time": "00:18:30",
  "completion_rate": 85.5,  // Pourcentage de complétion
  "best_score": 100,
  "worst_score": 20
}
```

**Utilisé dans:** Affichage des statistiques d'un quiz avant de le commencer.

---

### 5. **GET /quiz/user/rank** 🟡 PRIORITÉ MOYENNE
**Description:** Récupère le rang actuel de l'utilisateur dans le classement mensuel

**Méthode:** `GET`  
**Endpoint:** `/quiz/user/rank`

**Réponse attendue:**
```json
{
  "rank": 12,
  "total_players": 500,
  "score": 1850,
  "percentile": 97.6  // Pourcentage de joueurs battus
}
```

**Utilisé dans:** Affichage du rang dans les cartes de stats (alternative à l'endpoint stats complet).

---

## 📊 Résumé des Endpoints

### ✅ Endpoints Existants (6)
1. `GET /quiz` - Liste des quiz
2. `GET /quiz/{quizId}` - Détails d'un quiz
3. `POST /quiz/reponses/{quizId}` - Envoyer les réponses
4. `GET /quiz/{quizId}/bonnes-reponses` - Bonnes réponses
5. `GET /quiz/classement-general-mensuel` - Classement mensuel
6. `GET /quiz/{quizId}/classement` - Classement par quiz

### ❌ Endpoints à Ajouter (5)
1. 🔴 `GET /quiz/user/stats` - **PRIORITÉ HAUTE** (stats personnelles)
2. 🟡 `GET /quiz/user/history` - Historique des quiz joués
3. 🟡 `GET /quiz/user/result/{quizId}` - Résultat détaillé d'un quiz
4. 🟡 `GET /quiz/user/rank` - Rang de l'utilisateur
5. 🟢 `GET /quiz/{quizId}/stats` - Stats globales d'un quiz

---

## 🎯 Problèmes Actuels Identifiés

### 1. **Stats Hardcodées dans QuizHome**
**Fichier:** `lib/pages/quiz/home.dart` (lignes 285-295)

**Problème:**
```dart
value: '1,850',  // Hardcodé
value: '#12',    // Hardcodé
```

**Solution:** Utiliser `GET /quiz/user/stats` pour récupérer les vraies données.

---

### 2. **Pas d'historique des quiz joués**
**Problème:** Impossible de revoir les résultats passés d'un quiz.

**Solution:** Implémenter `GET /quiz/user/history` et `GET /quiz/user/result/{quizId}`.

---

### 3. **Pas de stats globales par quiz**
**Problème:** Impossible d'afficher le nombre de joueurs, score moyen, etc. avant de commencer un quiz.

**Solution:** Implémenter `GET /quiz/{quizId}/stats` (optionnel).

---

## 📝 Notes pour le Backend

### Format de Date
- Utiliser le format **ISO 8601** : `"2025-01-15T10:30:00Z"`
- Le frontend parse avec `DateTime.parse()`

### Format de Temps
- Format string : `"HH:mm:ss"` (ex: `"00:15:30"`)
- Ou format ISO 8601 duration : `"PT15M30S"`

### Structure des Réponses
- Toujours retourner un objet avec `data` pour les listes
- Codes de statut HTTP : 200 pour succès, 4xx pour erreurs client, 5xx pour erreurs serveur

### Authentification
- Tous les endpoints nécessitent l'authentification (token dans header `Authorization`)
- Les endpoints `/quiz/user/*` sont spécifiques à l'utilisateur connecté

---

## ✅ Checklist Backend

### Priorité HAUTE 🔴
- [ ] `GET /quiz/user/stats` - Stats personnelles

### Priorité MOYENNE 🟡
- [ ] `GET /quiz/user/history` - Historique
- [ ] `GET /quiz/user/result/{quizId}` - Résultat détaillé
- [ ] `GET /quiz/user/rank` - Rang utilisateur

### Priorité BASSE 🟢
- [ ] `GET /quiz/{quizId}/stats` - Stats globales quiz

---

## 🚀 Après Implémentation Backend

Une fois les endpoints ajoutés, je pourrai :
1. ✅ Remplacer les valeurs hardcodées par les vraies stats
2. ✅ Créer une page d'historique des quiz
3. ✅ Afficher les détails d'un résultat de quiz
4. ✅ Améliorer l'UX avec des données réelles


