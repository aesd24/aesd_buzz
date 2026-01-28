# 📲 Guide Complet d'Implémentation des Notifications

## ✅ Ce qui est Implémenté Côté Frontend

### 1. **Listeners Firebase Messaging** ✅
- ✅ `FirebaseMessaging.onMessage.listen()` - Messages en foreground
- ✅ `FirebaseMessaging.onMessageOpenedApp.listen()` - Notifications cliquées
- ✅ `getInitialMessage()` - Message au lancement de l'app
- ✅ Système anti-doublon avec cache temporaire (5 secondes)

### 2. **Modèle de Notification Amélioré** ✅
- ✅ Champs ajoutés: `servantId`, `postId`
- ✅ Parsing flexible du JSON (gère différents formats)
- ✅ Routes correctes: `Routes.postDetail`, `Routes.eventDetail`, etc.
- ✅ Navigation vers détails avec arguments corrects

### 3. **Provider Notification** ✅
- ✅ Récupération liste notifications (`getAll`)
- ✅ Compteur notifications non lues (`getUnreadCount`)
- ✅ Marquage comme lu (`markAsRead`, `markAllAsRead`)
- ✅ Gestion des erreurs gracieuse (404 endpoint, etc.)

### 4. **Page Notifications** ✅
- ✅ Liste moderne avec RefreshIndicator
- ✅ Bouton "Marquer tout comme lu"
- ✅ Badge compteur notifications
- ✅ Placeholder si aucune notification

### 5. **Service Messaging** ✅
- ✅ Snackbars personnalisés (success, error, warning, info)

---

## 📌 Flux Notification - Serviteur à Abonnés

### Scénario: Un serviteur crée un post → Ses abonnés reçoivent une notification

```
┌─────────────────────────────────────────────────────┐
│ 1. BACKEND: Serviteur crée un POST                  │
├─────────────────────────────────────────────────────┤
│ POST /api/posts                                     │
│ {                                                   │
│   "contenu": "Mon témoignage...",                   │
│   "image": "...",                                   │
│   "user_id": 123      // Serviteur                  │
│ }                                                   │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│ 2. BACKEND: Déclencher notification aux abonnés    │
├─────────────────────────────────────────────────────┤
│ - Récupérer tous les followers du serviteur        │
│ - Pour chaque follower:                             │
│   a) Créer une entrée en DB (notifications table)   │
│   b) Envoyer notification Firebase (FCM)            │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│ 3. FIREBASE: Envoyer notification au device        │
├─────────────────────────────────────────────────────┤
│ {                                                   │
│   "notification": {                                 │
│     "title": "Nouveau post",                        │
│     "body": "Nom du serviteur a publié..."         │
│   },                                                │
│   "data": {                                         │
│     "type": "post",          // Type d'action      │
│     "id": "456",             // ID du post         │
│     "servant_id": "123",     // ID du serviteur    │
│     "post_id": "456"         // Redondant mais OK  │
│   },                                                │
│   "token": "fcm_token_user"   // Token de l'user   │
│ }                                                   │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│ 4. FRONTEND: Recevoir et traiter notification     │
├─────────────────────────────────────────────────────┤
│ onMessage / onMessageOpenedApp listener              │
│   └─> _handleMessage()                              │
│       ├─> Vérifier doublon (cache de 5s)           │
│       └─> Get.toNamed(Routes.postDetail,           │
│           arguments: {'postId': 456})               │
│           ✅ Redirection vers le POST créé          │
└─────────────────────────────────────────────────────┘
```

---

## 🔧 Endpoints Backend Requis

### 1. **Créer une notification**
```bash
POST /api/notifications
Content-Type: application/json
Authorization: Bearer {token}

{
  "user_id": 789,           // ID utilisateur qui reçoit
  "title": "Nouveau post",
  "content": "Nom du serviteur a publié un nouveau post",
  "type": "post",           // post, event, ceremony, quiz, forum
  "post_id": 456,           // ID de la ressource
  "servant_id": 123,        // ID du serviteur (creator)
  "readed": 0
}

Réponse:
{
  "id": 1,
  "user_id": 789,
  "title": "Nouveau post",
  "content": "...",
  "type": "post",
  "post_id": 456,
  "servant_id": 123,
  "readed": 0,
  "date": "2025-01-27T10:30:00Z"
}
```

### 2. **Récupérer notifications utilisateur**
```bash
GET /api/notifications?page=1
Authorization: Bearer {token}

Réponse:
{
  "data": [
    {
      "id": 1,
      "title": "Nouveau post",
      "content": "Nom a publié...",
      "type": "post",
      "post_id": 456,
      "servant_id": 123,
      "date": "2025-01-27T10:30:00Z",
      "readed": 0,
      "notificationType": "post"
    }
  ],
  "unread_count": 5
}
```

### 3. **Marquer notification comme lue**
```bash
PUT /api/notifications/{id}/read
Authorization: Bearer {token}

Réponse: 200 OK
```

### 4. **Marquer tout comme lu**
```bash
PUT /api/notifications/read-all
Authorization: Bearer {token}

Réponse: 200 OK
```

### 5. **Envoyer notification via FCM**
```bash
POST /api/notifications/send-fcm
Content-Type: application/json

{
  "user_id": 789,
  "title": "Nouveau post",
  "body": "Nom du serviteur a publié...",
  "type": "post",
  "post_id": 456,
  "servant_id": 123
}
```

---

## 🚀 Procédure Backend - Quand un Serviteur Poste

### Pseudo-code Laravel

```php
// Dans PostController@store

public function store(Request $request)
{
    $validated = $request->validate([
        'contenu' => 'required|string',
        'image' => 'nullable|image',
    ]);

    // 1. Créer le post
    $post = Post::create([
        'contenu' => $validated['contenu'],
        'image' => $validated['image'] ?? null,
        'user_id' => auth()->id(),
        'created_at' => now(),
    ]);

    // 2. Récupérer l'utilisateur actuel (le serviteur)
    $servant = auth()->user();
    
    // 3. Récupérer tous les followers/abonnés du serviteur
    // (Adapter selon votre structure DB)
    $followers = $servant->followers()->get();
    
    // 4. Pour chaque abonné, créer une notification
    foreach ($followers as $follower) {
        // Créer la notification en DB
        Notification::create([
            'user_id' => $follower->id,
            'title' => 'Nouveau post',
            'content' => $servant->name . ' a publié un nouveau post',
            'type' => 'post',
            'post_id' => $post->id,
            'servant_id' => $servant->id,
            'readed' => 0,
            'date' => now(),
        ]);

        // Envoyer la notification Firebase
        $this->sendFirebaseNotification(
            user: $follower,
            title: 'Nouveau post',
            body: $servant->name . ' a publié',
            type: 'post',
            post_id: $post->id,
            servant_id: $servant->id,
        );
    }

    return response()->json(['post' => $post], 201);
}

// Helper pour envoyer notification Firebase
private function sendFirebaseNotification($user, $title, $body, $type, $post_id, $servant_id)
{
    // Récupérer le FCM token de l'utilisateur
    $fcmToken = $user->fcm_token; // Assurer qu'il est stocké lors de la connexion
    
    if (!$fcmToken) return;

    // Utiliser Firebase Admin SDK (ou service tiers)
    $messaging = app('firebase.messaging');
    
    $message = [
        'notification' => [
            'title' => $title,
            'body' => $body,
        ],
        'data' => [
            'type' => $type,
            'id' => (string) $post_id,
            'post_id' => (string) $post_id,
            'servant_id' => (string) $servant_id,
        ],
        'token' => $fcmToken,
    ];

    try {
        $messaging->send($message);
    } catch (\Exception $e) {
        Log::error('Erreur FCM: ' . $e->getMessage());
    }
}
```

---

## 🔒 Éviter les Doublons

### Frontend
✅ **Implémenté**: Cache `_notificationIds` avec timeout de 5s
- Chaque notification reçue est enregistrée avec son messageId
- Même notification cliquée = ignorée

### Backend
📋 **À implémenter (recommandé)**:
```php
// Vérifier si notification existe déjà
$exists = Notification::where('user_id', $follower->id)
    ->where('type', 'post')
    ->where('post_id', $post->id)
    ->where('created_at', '>=', now()->subMinutes(1)) // À peine créée
    ->exists();

if ($exists) continue; // Ne pas créer de doublon
```

---

## 📱 Flux FCM Token

### 1. **Lors de la connexion**: Stocker le FCM token
```dart
// Dans AuthProvider après login réussi
String? fcmToken = await FirebaseMessaging.instance.getToken();
await authRequest.updateFcmToken(fcmToken);
```

### 2. **Endpoint backend**
```bash
PUT /api/user/fcm-token
Authorization: Bearer {token}

{
  "fcm_token": "..."
}
```

---

## 🎯 Checklist Implémentation

- [x] Frontend: Listeners Firebase complets
- [x] Frontend: Model NotificationModel avec champs servantId/postId
- [x] Frontend: Routes correctes (Routes.postDetail, etc.)
- [x] Frontend: Anti-doublon avec cache
- [x] Frontend: Provider NotificationProvider ajouté à main.dart
- [ ] Backend: Endpoint POST /api/notifications (créer)
- [ ] Backend: Endpoint GET /api/notifications (lister)
- [ ] Backend: Endpoint PUT /api/notifications/{id}/read
- [ ] Backend: Endpoint PUT /api/notifications/read-all
- [ ] Backend: Envoyer FCM lors de création de post
- [ ] Backend: Gestion followers/subscriptions
- [ ] Backend: Vérification des doublons
- [ ] Backend: Stockage FCM token lors login
- [ ] Test: Créer post → Vérifier notification reçue
- [ ] Test: Clic notification → Redirection correcte
- [ ] Test: Pas de double notification

---

## 📞 Support des Types

| Type | Route | Arguments | Exemple |
|------|-------|-----------|---------|
| `post` | `Routes.postDetail` | `{'postId': 456}` | Post d'un utilisateur |
| `event` | `Routes.eventDetail` | `{'eventId': 456}` | Événement créé |
| `ceremony` | `Routes.ceremonyDetail` | `{'ceremonyId': 456}` | Cérémonie |
| `quiz` | `Routes.postDetail` | `{'postId': 456}` | Quiz (via post) |
| `forum` | `Routes.subject` | `{'subjectId': 456}` | Sujet forum |

---

## 🐛 Debugging

### Android Logcat
```bash
flutter logs --grep="Notification\|Firebase\|FCM"
```

### Afficher les notifications envoyées
```dart
print('Notification reçue: ${message.data}');
```

### Test Firebase Messaging
```bash
firebase emulator:start  # Lancer émulateur
```
