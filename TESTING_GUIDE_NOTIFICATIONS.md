# 🧪 Guide de Test - Système de Notifications

## 📱 Prérequis

- ✅ App Flutter en développement
- ✅ Firebase configuré
- ✅ Device/Émulateur avec Google Play Services
- ✅ FCM tokens sauvegardés côté backend
- ✅ Endpoints API implémentés au backend

---

## 🔬 Test 1: Message en Foreground (App Ouverte)

### Scénario
L'app est ouverte au premier plan, on reçoit une notification Firebase.

### Procédure

1. **Lancer l'app en debug**:
```bash
flutter run -v
```

2. **Garder l'app ouverte** et en avant-plan

3. **Déclencher une notification** depuis le backend:
```bash
curl -X POST https://api.monapi.com/api/notifications/send-fcm \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "title": "Nouveau post",
    "body": "Jean a publié un post",
    "type": "post",
    "post_id": 123,
    "servant_id": 5
  }'
```

### ✅ Résultat Attendu

**Console Flutter**:
```
I/flutter: Notification reçue: {type: post, id: 123, servant_id: 5, post_id: 123}
```

**Pas de redirection** (l'app est déjà ouverte), juste enregistrement du message.

---

## 🔬 Test 2: Notification Cliquée (App en Background/Fermée)

### Scénario
L'app est en arrière-plan ou fermée. On reçoit une notification, on clique dessus.

### Procédure

1. **Lancer l'app en debug**:
```bash
flutter run -v
```

2. **Minimiser l'app** (sans la fermer complètement)
- Android: Appuyer sur le bouton Home
- iOS: Faire un swipe up depuis le bas

3. **Déclencher une notification**:
```bash
curl -X POST https://api.monapi.com/api/notifications/send-fcm \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "title": "Nouveau post",
    "body": "Jean a publié un post",
    "type": "post",
    "post_id": 123,
    "servant_id": 5
  }'
```

4. **Attendre la notification** (zone de notification)

5. **Cliquer sur la notification**

### ✅ Résultat Attendu

**Console Flutter**:
```
I/flutter: App ouvert via notification: {type: post, id: 123, servant_id: 5, post_id: 123}
I/flutter: Redirection vers: Routes.postDetail
```

**L'app se relance** et affiche le **détail du post #123** ✨

---

## 🔬 Test 3: App Lancée via Notification (App Fermée)

### Scénario
L'app est complètement fermée. Une notification arrive. On clique dessus.

### Procédure

1. **Lancer l'app en debug**:
```bash
flutter run -v
```

2. **Fermer complètement l'app**:
- Android: Appuyer sur "Récent" → Glisser l'app vers le haut (ou Ctrl+C dans le terminal)
- iOS: Fermer depuis l'app switcher

3. **Déclencher une notification**:
```bash
curl -X POST https://api.monapi.com/api/notifications/send-fcm \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "title": "Nouveau post",
    "body": "Jean a publié un post",
    "type": "post",
    "post_id": 123,
    "servant_id": 5
  }'
```

4. **Attendre la notification** dans la zone de notification

5. **Cliquer sur la notification**

### ✅ Résultat Attendu

**L'app démarre** et affiche **directement le post #123** sans passer par l'accueil ✨

**Console Flutter** (une fois l'app attachée):
```
I/flutter: App ouvert via notification: {type: post, id: 123, servant_id: 5, post_id: 123}
```

---

## 🔬 Test 4: Prévention des Doublons

### Scénario
Vérifier que la même notification n'est pas traitée plusieurs fois.

### Procédure

1. **Ajouter un log custom** dans `_handleMessage()`:
```dart
void _handleMessage(RemoteMessage message, {bool isFromNotification = false}) async {
  String notificationId = message.messageId ?? message.sentTime.toString();
  print('🔔 Traitement notif: $notificationId');
  
  if (_notificationIds.contains(notificationId) && isFromNotification) {
    print('⚠️ DOUBLON DÉTECTÉ: $notificationId - IGNORÉ');
    return;
  }
  print('✅ Nouvelle notif: $notificationId - TRAITÉE');
  // ... reste du code
}
```

2. **Relancer l'app**:
```bash
flutter run -v
```

3. **Garder l'app en arrière-plan**

4. **Envoyer DEUX fois la même notification** très rapidement:
```bash
# Première fois
curl -X POST https://api.monapi.com/api/notifications/send-fcm \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "type": "post", "post_id": 123}'

# Immédiatement après
curl -X POST https://api.monapi.com/api/notifications/send-fcm \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "type": "post", "post_id": 123}'
```

5. **Cliquer sur une notification**

### ✅ Résultat Attendu

**Console Flutter**:
```
I/flutter: 🔔 Traitement notif: abc123def456
I/flutter: ✅ Nouvelle notif: abc123def456 - TRAITÉE

I/flutter: 🔔 Traitement notif: abc123def456
I/flutter: ⚠️ DOUBLON DÉTECTÉ: abc123def456 - IGNORÉ
```

**Résultat**: Une seule redirection vers le post, pas deux ✨

---

## 🔬 Test 5: Différents Types de Notifications

### Scénario
Tester que chaque type de notification redirige correctement.

### Types à tester

```dart
// 1. POST
{
  "type": "post",
  "post_id": 123,
  // → Routes.postDetail avec {'postId': 123}
}

// 2. EVENT
{
  "type": "event",
  "post_id": 456,
  // → Routes.eventDetail avec {'eventId': 456}
}

// 3. CEREMONY
{
  "type": "ceremony",
  "post_id": 789,
  // → Routes.ceremonyDetail avec {'ceremonyId': 789}
}

// 4. QUIZ
{
  "type": "quiz",
  "post_id": 321,
  // → Routes.postDetail avec {'postId': 321}
}

// 5. FORUM
{
  "type": "forum",
  "post_id": 654,
  // → Routes.subject avec {'subjectId': 654}
}
```

### Procédure

1. **Pour chaque type**, envoyer une notification:
```bash
curl -X POST https://api.monapi.com/api/notifications/send-fcm \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "title": "Nouveau post",
    "body": "Test",
    "type": "post",
    "post_id": 123,
    "servant_id": 5
  }'
```

2. **Cliquer sur la notification**

3. **Vérifier la redirection** vers la bonne page

### ✅ Résultat Attendu

Chaque type redirige vers la **bonne page** avec les **bons arguments**.

---

## 🔬 Test 6: Routes correctes

### Vérifier que les routes utilisées sont correctes

### Procédure

1. **Ouvrir la console Flutter**:
```bash
flutter logs --grep="Redirection\|Routes"
```

2. **Envoyer une notification**:
```bash
curl -X POST https://api.monapi.com/api/notifications/send-fcm \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "type": "post", "post_id": 123}'
```

3. **Cliquer sur la notification**

### ✅ Résultat Attendu

**Pas d'erreurs** du type:
- ❌ `Route not found: /post-detail`
- ❌ `Unknown route: /event-detail`

Les routes utilisées doivent être les constantes de `Routes` ✅

---

## 🔬 Test 7: Arguments Corrects

### Vérifier que les arguments passés sont corrects

### Procédure

1. **Dans PostDetail**, ajouter un print**:
```dart
class PostDetail extends StatefulWidget {
  @override
  void didUpdateWidget(PostDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('PostDetail reçu postId: ${Get.arguments['postId']}');
  }
}
```

2. **Envoyer une notification**:
```bash
curl -X POST https://api.monapi.com/api/notifications/send-fcm \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "type": "post", "post_id": 42}'
```

3. **Cliquer sur la notification**

### ✅ Résultat Attendu

**Console**:
```
I/flutter: PostDetail reçu postId: 42
```

Le post avec l'ID **42** est affichée correctement ✅

---

## 🔬 Test 8: FCM Token Gestion

### Vérifier que le token FCM est correctement stocké

### Procédure

1. **Lors du login**, capturer le token:
```dart
String? fcmToken = await FirebaseMessaging.instance.getToken();
print('FCM Token: $fcmToken');
// Envoyer au backend
```

2. **Vérifier en base de données**:
```bash
# Côté backend
SELECT fcm_token FROM users WHERE id = 1;
# Doit afficher le token reçu
```

### ✅ Résultat Attendu

Le **token FCM** est stocké en base de données ✅

---

## 🔬 Test 9: Notifications Serviteur à Abonnés

### Scénario Complet
Un serviteur crée un post → Ses abonnés reçoivent une notification

### Procédure

1. **User A** (serviteur) créé un post:
```bash
POST /api/posts
{
  "contenu": "Mon témoignage...",
  "user_id": 5
}
```

2. **User B** et **User C** sont abonnés à User A

3. **Backend déclenche notif** pour User B et User C

4. **User B reçoit la notification** → Clique dessus → **Voit le post du serviteur**

### ✅ Résultat Attendu

- User B voit le post de User A (servant) ✅
- User C voit aussi le post ✅
- Tous deux voient les mêmes informations ✅

---

## 📋 Checklist de Test

```
□ Test 1: Message en foreground - Console log visible
□ Test 2: App en background + clic - Redirection OK
□ Test 3: App fermée + clic - Démarrage + redirection OK
□ Test 4: Doublon ignoré - Cache 5s fonctionne
□ Test 5: Type POST - Redirection Routes.postDetail
□ Test 5: Type EVENT - Redirection Routes.eventDetail
□ Test 5: Type CEREMONY - Redirection Routes.ceremonyDetail
□ Test 5: Type QUIZ - Redirection Routes.postDetail
□ Test 5: Type FORUM - Redirection Routes.subject
□ Test 6: Routes correctes - Pas d'erreur /post-detail
□ Test 7: Arguments corrects - postId=42 affiché
□ Test 8: FCM Token stocké - Base de données OK
□ Test 9: Serviteur → Abonnés - Notification reçue
```

---

## 🐛 Debugging

### Logs utiles

```bash
# Tous les logs notifications
flutter logs --grep="Notification\|FCM\|Firebase\|postId"

# Logs d'erreurs
flutter logs --grep="error\|Error\|ERROR"

# Logs spécifiques
flutter logs --grep="Redirection\|doublon\|Routes"
```

### Vérifier le JSON reçu

Ajouter dans `_handleMessage()`:
```dart
print('📦 Message complet: ${message.toMap()}');
print('📋 Data: ${message.data}');
print('🔔 Notification: ${message.notification?.toMap()}');
```

---

## ⚠️ Problèmes Courants

### Problème 1: Notification pas reçue
- ✅ Vérifier que l'app est lancée au moins une fois
- ✅ Vérifier que Firebase est configuré
- ✅ Vérifier que le FCM token est envoyé au backend
- ✅ Vérifier que le device a Google Play Services

### Problème 2: Redirection incorrecte
- ✅ Vérifier que le `type` est correct (post, event, etc.)
- ✅ Vérifier que le `post_id` ou `id` est fourni
- ✅ Vérifier que les routes existent dans `Routes` class

### Problème 3: Doublon reçu
- ✅ Vérifier que `_notificationIds` cache fonctionne
- ✅ Vérifier que le timeout 5s est respecté
- ✅ Vérifier que l'ID de notification est unique

### Problème 4: Erreur de parsing JSON
- ✅ Vérifier que le JSON envoyé est valide
- ✅ Vérifier que les champs `type` et `id` existent
- ✅ Vérifier que les types supportés sont utilisés

---

## 📞 Support

Si un test échoue:
1. Vérifier les **logs console Flutter**
2. Vérifier les **réponses API backend**
3. Vérifier que les **données FCM** sont valides
4. Vérifier la **structure JSON** envoyée

Tous les éléments sont documentés dans:
- [NOTIFICATION_IMPLEMENTATION_GUIDE.md](NOTIFICATION_IMPLEMENTATION_GUIDE.md)
- [NOTIFICATION_IMPLEMENTATION_SUMMARY.md](NOTIFICATION_IMPLEMENTATION_SUMMARY.md)
