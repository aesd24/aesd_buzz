# ✅ Prévention de Rejeu Quiz - IMPLÉMENTÉE

## 📋 Résumé des Modifications

La prévention de rejeu a été implémentée sur **3 niveaux**:

### 1️⃣ **Frontend - Blocage au niveau de la carte (buildModernCard)**
- Désactivation du bouton si `hasPlayed = true`
- Texte du bouton change en "Terminé" avec ✓ icon
- Badge vert "Complété" affiché en haut à droite de la carte

**Visuel:**
```
┌─────────────────────────────────┐
│  [Vert: ✓ Complété] 📖         │
│                                 │
│  Quiz: Fondements de la foi... │
│  Facile                         │
│                                 │
│  10 Questions  | 30 min        │
│  150 joueurs   | 11 pts        │
│                                 │
│  ┌─────────────────────────┐   │
│  │ ✓ Terminé (Désactivé)   │   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
```

### 2️⃣ **Frontend - Blocage à l'entrée de la page (answer.dart)**
Vérification dans `initState()`:
```dart
if (widget.quiz.hasPlayed) {
  MessageService.showErrorMessage(
    "Vous avez déjà joué ce quiz ce mois-ci",
  );
  Future.delayed(Duration(milliseconds: 500), () => Get.back());
  return;
}
```

**Effet:**
- Message d'erreur rouge affiché
- Retour auto à la page précédente (500ms après)
- Timer ne démarre pas

### 3️⃣ **Backend - Vérification supplémentaire (Laravel)**
*(À implémenter côté serveur)*

```php
// Dans GET /quiz/{id}
if ($hasPlayedThisMonth) {
    return response()->json(['error' => 'Déjà joué'], 403);
}

// Dans POST /quiz/reponses/{id}
if ($alreadyPlayed) {
    return response()->json(['error' => 'Rejeu détecté'], 403);
}
```

---

## 🔄 Flux de Prévention

### Scénario: Utilisateur essaie de rejouer un quiz complété

```
1. Page QuizHome
   ├─ Quiz affiché avec badge "✓ Complété"
   ├─ Bouton "Terminé" (désactivé)
   └─ hasPlayed = true

2. Utilisateur click sur carte (même si désactivé)
   └─ onTap = null (rien ne se passe)

3. Si le bouton était activable (hack), go to AnswerPage
   └─ answer.dart détecte hasPlayed = true dans initState()
   └─ Message: "Vous avez déjà joué ce quiz ce mois-ci"
   └─ Retour auto à page précédente

4. Backend (sécurité supplémentaire)
   ├─ GET /quiz/{id}:
   │  └─ 403 Forbidden si hasPlayed
   └─ POST /quiz/reponses/{id}:
      └─ 403 Forbidden si already_played
```

---

## 📝 Modifications Détaillées

### Fichier: lib/models/quiz_model.dart

#### Avant
```dart
Container(
  child: InkWell(
    onTap: hasPlayed ? null : () => Get.to(...),
    child: Container(...),
  ),
),
```

#### Après
```dart
Stack(
  children: [
    Container(
      child: Column(...),
    ),
    
    // ✅ Badge "Complété"
    if (hasPlayed)
      Positioned(
        top: 8,
        right: 8,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(FontAwesomeIcons.check, color: Colors.white, size: 12),
              Text('Complété', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
  ],
),
```

### Fichier: lib/pages/quiz/answer.dart

#### Ajout dans initState()
```dart
@override
void initState() {
  super.initState();
  
  // ✅ NOUVEAU: Vérifier que le quiz n'a pas déjà été joué
  if (widget.quiz.hasPlayed) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MessageService.showErrorMessage(
        "Vous avez déjà joué ce quiz ce mois-ci",
      );
      Future.delayed(Duration(milliseconds: 500), () => Get.back());
    });
    return;
  }
  
  _timer = Timer.periodic(...);
  _updateCurrentQuestion();
}
```

---

## ✅ Comportement Utilisateur

### Scénario 1: Quiz Non Joué
```
Status: hasPlayed = false

Visuel:
├─ Pas de badge
├─ Bouton "Commencer" (activé)
└─ Couleur: Gradient normal

Action: Click bouton
└─ → Accès au quiz OK ✅
```

### Scénario 2: Quiz Complété
```
Status: hasPlayed = true

Visuel:
├─ Badge vert "✓ Complété" en haut à droite
├─ Bouton "Terminé" (désactivé, grisé)
└─ Couleur: Légèrement estompée

Action: Click sur la carte
└─ → Rien ne se passe (onTap = null)

Action: Même si button était activable
└─ answer.dart détecte hasPlayed
└─ Message erreur
└─ Retour auto à QuizHome
```

### Scénario 3: Quiz Expiré
```
Status: isAvailable = false

Visuel:
├─ Bouton "Non disponible" (désactivé)
└─ Couleur: Dégradée

Action: Click
└─ → Rien ne se passe
```

---

## 🔐 Niveaux de Sécurité

| Niveau | Localisation | Mécanisme | Force |
|--------|-------------|-----------|-------|
| 1️⃣ UI | QuizHome | onTap = null | Faible (côté client) |
| 2️⃣ Navigation | AnswerPage | initState check | Moyen (redirection rapide) |
| 3️⃣ Backend | Laravel | POST validation | Fort (serveur) |

**Recommandation:** Tous les 3 niveaux devraient être actifs pour une sécurité optimale.

---

## 🎯 Données Requises du Backend

```json
{
  "has_played": true|false,      // ✅ REQUIS
  "points_maximal": 11,           // Pour afficher points
  "created_at": "2026-01-27...",  // Pour date
  "date": "2026-01-27..."         // Pour expiryDate
}
```

### Points de Contrôle

- ✅ `hasPlayed` = true/false basé sur user_quiz du mois courant
- ✅ Reset mensuel (reset chaque mois)
- ✅ Par quiz (utilisateur peut jouer quiz A mais pas quiz B si A déjà joué)

---

## 📊 État QuizModel

```dart
class QuizModel {
  late bool hasPlayed;           // ← Clé de la prévention
  late DateTime expiryDate;      // Pour isAvailable
  late bool isAvailable;         // Calculé: now < expiryDate
  late int totalPoints;
  List questions = [];
}
```

**Logique:**
- `hasPlayed` vient du backend (user_quiz du mois courant)
- `isAvailable` = `DateTime.now().isBefore(expiryDate)`
- Bouton désactivé si: `hasPlayed || !isAvailable`

---

## 🚀 Prochaines Étapes

### ✅ Fait
- [x] Frontend: Blocage UI (bouton désactivé)
- [x] Frontend: Badge visuel "Complété"
- [x] Frontend: Check initState() avec message
- [x] Frontend: Redirection auto si hasPlayed

### ⏳ À Faire (Backend)
- [ ] Vérifier GET /quiz/{id} retourne `has_played` correct
- [ ] Ajouter check dans GET /quiz/{id} - return 403 si hasPlayed
- [ ] Ajouter check dans POST /quiz/reponses/{id} - return 403 si rejeu
- [ ] Implémenter logique reset mensuel
- [ ] Tests API avec Swagger/Postman

### 🎯 Optionnel
- [ ] Ajouter animation "shake" si click sur quiz complété
- [ ] Toast message "Déjà joué ce mois-ci"
- [ ] Afficher date de complétude dans le badge
- [ ] Permettre rejeu après fin du mois (reset)

---

## 🧪 Tests Recommandés

### Test 1: Prévention UI
```
1. Charger quiz avec hasPlayed = true
2. Vérifier badge "✓ Complété" visible
3. Vérifier bouton "Terminé" (désactivé)
4. Click bouton → Rien ne se passe ✓
```

### Test 2: Prévention Navigation
```
1. Modifier QuizModel manuellement: hasPlayed = true
2. Naviguer vers AnswerPage avec ce quiz
3. Message apparaît: "Vous avez déjà joué ce quiz ce mois-ci"
4. Auto-redirection vers QuizHome ✓
```

### Test 3: Prévention Backend
```
1. POST à /quiz/reponses/{id} après avoir joué
2. Backend retourne 403 Forbidden ✓
```

---

## 💡 Notes Techniques

### hasPlayed Reset
```php
// Reset automatique chaque mois
$quizzes->where(function($query) {
    return $query->where('user_id', auth()->id())
                ->whereMonth('created_at', now()->month)
                ->whereYear('created_at', now()->year);
});
```

### hasPlayed Calculation (Backend)
```dart
// Frontend: Vérifier les valeurs
bool hasPlayed = json['has_played'] ?? false;

// Définition backend: 
// hasPlayed = 1 si EXISTS (user_quiz où month=current)
```

### Message Multilingue (Optionnel)
```dart
final message = user.locale == 'fr'
    ? "Vous avez déjà joué ce quiz ce mois-ci"
    : "You already played this quiz this month";
```

