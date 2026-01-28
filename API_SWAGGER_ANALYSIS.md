# 📋 ANALYSE API Swagger - État des Notifications

## ✅ Ce qui Existe dans l'API

```
✅ Auth:
   - /register (POST)
   - /login (POST)
   - /logout (POST)
   - /password/forgot (POST)
   - /verify-Otp (POST)
   - /password/reset (POST)
   - /user_auth_infos (GET)
   - /user/{id} (GET)
   - /update-password (POST)
   - /update-profile (POST)
   - /user (GET)

✅ Churches:
   - /churches (GET, POST)
   - /churches/{id} (GET, POST, DELETE)
   - /churches/serviteur_church (GET)
   - /churches/{id}/subscribe (POST)
   - /church-photos/* (GET, POST, DELETE)
   - /church-annexes (POST)
   - /churches/{churchId}/membership-request (POST)
   - /membership-requests/* (GET, POST)

✅ Posts:
   - /posts (GET, POST)
   - /posts/{post} (GET, POST, DELETE)
   - /posts/servant (GET)
   - /posts/comments/{post} (POST)
   - /posts/like/{postId} (POST)
   - /posts/servant-posts (GET)
   - /posts/servants/{id}/posts (GET)

✅ Events:
   - /events (GET, POST)
   - /events/{id} (GET)
   - /events/show/{id} (GET)
   - /events/{evenement} (POST, DELETE)
   - /events/{evenement}/publish-now (POST)
   - /events/{evenement}/schedule-publication (POST)
   - /events/{evenement}/stop-publication (POST)

✅ Serviteurs:
   - /serviteurs (GET)
   - /serviteurs/{id} (GET)
   - /serviteur/{id} (GET)
   - /serviteur/abonnements (GET)
   - /serviteur/abonnes (GET)
   - /serviteurs/subscribe/{id} (POST)

✅ Quiz, Sujets, Témoignages, Programmes, Cérémonies, etc.

❌ NOTIFICATIONS: **COMPLÈTEMENT ABSENT**
```

---

## ❌ Ce qui Manque pour les Notifications

```
❌ /notifications (GET) - Lister notifications
❌ /notifications/{id} (GET) - Détail notification
❌ /notifications/{id}/read (PUT) - Marquer comme lu
❌ /notifications/read-all (PUT) - Marquer tout comme lu
❌ /notifications/unread-count (GET) - Compteur non lues
❌ /user/fcm-token (PUT) - Stocker token FCM
❌ /notifications/send-fcm (POST) - Tester/Envoyer FCM (test)
```

---

## 🎯 Plan d'Implémentation Backend

### 1. **Modèle Notification (Laravel)**
```php
// database/migrations/create_notifications_table.php
Schema::create('notifications', function (Blueprint $table) {
    $table->id();
    $table->unsignedBigInteger('user_id');
    $table->string('title');
    $table->text('content');
    $table->enum('type', ['post', 'event', 'ceremony', 'quiz', 'forum']);
    $table->unsignedBigInteger('post_id')->nullable();
    $table->unsignedBigInteger('servant_id')->nullable();
    $table->boolean('readed')->default(false);
    $table->timestamp('date')->useCurrent();
    $table->timestamps();
    
    $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
});

// database/migrations/add_fcm_token_to_users_table.php
Schema::table('users', function (Blueprint $table) {
    $table->string('fcm_token')->nullable();
});
```

### 2. **Contrôleur Notification**
```php
// app/Http/Controllers/NotificationController.php
class NotificationController extends Controller {
    
    // GET /api/notifications
    public function index() { ... }
    
    // GET /api/notifications/{id}
    public function show($id) { ... }
    
    // PUT /api/notifications/{id}/read
    public function markAsRead($id) { ... }
    
    // PUT /api/notifications/read-all
    public function markAllAsRead() { ... }
    
    // GET /api/notifications/unread-count
    public function unreadCount() { ... }
    
    // POST /api/notifications (interne - créer)
    public function store(Request $request) { ... }
    
    // POST /api/notifications/send-fcm (test)
    public function testFcm(Request $request) { ... }
}
```

### 3. **Service FCM**
```php
// app/Services/FirebaseService.php
class FirebaseService {
    
    public function sendNotification($userId, $title, $body, $data = []) {
        $user = User::find($userId);
        if (!$user || !$user->fcm_token) return false;
        
        // Utiliser Firebase Admin SDK
        $messaging = app('firebase.messaging');
        
        $message = [
            'notification' => ['title' => $title, 'body' => $body],
            'data' => $data,
            'token' => $user->fcm_token,
        ];
        
        return $messaging->send($message);
    }
}
```

### 4. **Routes API**
```php
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::get('/notifications/{id}', [NotificationController::class, 'show']);
    Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    
    // FCM Token
    Route::put('/user/fcm-token', [UserController::class, 'updateFcmToken']);
    
    // Test FCM (admin only)
    Route::post('/notifications/send-fcm', [NotificationController::class, 'testFcm']);
});
```

### 5. **Logique Post Creation - Déclencher Notifications**
```php
// app/Http/Controllers/PostController.php
public function store(Request $request) {
    $post = Post::create([...]);
    
    // Récupérer les followers du serviteur
    $followers = auth()->user()->followers()->pluck('id');
    
    // Créer notification pour chaque follower
    foreach ($followers as $userId) {
        Notification::create([
            'user_id' => $userId,
            'title' => 'Nouveau post',
            'content' => auth()->user()->name . ' a publié un nouveau post',
            'type' => 'post',
            'post_id' => $post->id,
            'servant_id' => auth()->id(),
            'readed' => false,
        ]);
        
        // Envoyer FCM
        app(FirebaseService::class)->sendNotification(
            userId: $userId,
            title: 'Nouveau post',
            body: auth()->user()->name . ' a publié',
            data: [
                'type' => 'post',
                'id' => (string)$post->id,
                'servant_id' => (string)auth()->id(),
                'post_id' => (string)$post->id,
            ]
        );
    }
    
    return response()->json(['post' => $post], 201);
}
```

---

## 📊 Endpoints à Créer - Détails Complets

### 1. **GET /api/notifications**
```json
// Requête
GET /api/notifications?page=1
Authorization: Bearer {token}

// Réponse 200
{
  "data": [
    {
      "id": 1,
      "user_id": 789,
      "title": "Nouveau post",
      "content": "Jean a publié un post",
      "type": "post",
      "post_id": 456,
      "servant_id": 123,
      "readed": 0,
      "date": "2026-01-27T10:30:00Z",
      "notificationType": "post"
    }
  ],
  "unread_count": 5,
  "pagination": { ... }
}
```

### 2. **GET /api/notifications/{id}**
```json
// Requête
GET /api/notifications/1
Authorization: Bearer {token}

// Réponse 200
{
  "id": 1,
  "title": "Nouveau post",
  "content": "...",
  "type": "post",
  "post_id": 456,
  "servant_id": 123,
  "readed": 0,
  "date": "2026-01-27T10:30:00Z"
}
```

### 3. **PUT /api/notifications/{id}/read**
```json
// Requête
PUT /api/notifications/1/read
Authorization: Bearer {token}

// Réponse 200
{
  "message": "Notification marquée comme lue",
  "notification": { ... }
}
```

### 4. **PUT /api/notifications/read-all**
```json
// Requête
PUT /api/notifications/read-all
Authorization: Bearer {token}

// Réponse 200
{
  "message": "Toutes les notifications ont été marquées comme lues",
  "count": 5
}
```

### 5. **GET /api/notifications/unread-count**
```json
// Requête
GET /api/notifications/unread-count
Authorization: Bearer {token}

// Réponse 200
{
  "count": 5,
  "unread_count": 5
}
```

### 6. **PUT /api/user/fcm-token**
```json
// Requête
PUT /api/user/fcm-token
Authorization: Bearer {token}
Content-Type: application/json

{
  "fcm_token": "eXpabcdefg123..."
}

// Réponse 200
{
  "message": "Token FCM mis à jour",
  "fcm_token": "eXpabcdefg123..."
}
```

### 7. **POST /api/notifications/send-fcm** (Test)
```json
// Requête
POST /api/notifications/send-fcm
Authorization: Bearer {token}
Content-Type: application/json

{
  "user_id": 789,
  "title": "Test notification",
  "body": "Ceci est une notification de test",
  "type": "post",
  "post_id": 456,
  "servant_id": 123
}

// Réponse 200
{
  "message": "Notification envoyée avec succès",
  "notification_id": 1
}

// Réponse 400
{
  "message": "Token FCM non trouvé pour l'utilisateur"
}
```

---

## 🔄 Étapes Implémentation (Ordre Recommandé)

1. **Migration**: Créer table `notifications` et ajouter `fcm_token` à `users`
2. **Modèle**: Créer `app/Models/Notification.php`
3. **Controller**: Créer `app/Http/Controllers/NotificationController.php`
4. **Service**: Créer `app/Services/FirebaseService.php`
5. **Routes**: Ajouter les 7 endpoints dans `routes/api.php`
6. **Observer/Event**: Hook sur création de post → déclencher notifications
7. **Tests**: Tester chaque endpoint
8. **Swagger**: Documenter les endpoints

---

## 📋 Checklist Backend

- [ ] Migration notifications table
- [ ] Migration fcm_token users
- [ ] Modèle Notification
- [ ] Contrôleur NotificationController (7 méthodes)
- [ ] Service FirebaseService
- [ ] Routes API (7 endpoints)
- [ ] Observer PostObserver (déclencher notif lors post)
- [ ] Tests unitaires
- [ ] Tests d'intégration
- [ ] Documentation Swagger
- [ ] Gestion erreurs
- [ ] Logs
- [ ] Validation inputs
- [ ] Permissions/authorization
- [ ] Rate limiting (optionnel)

---

## ⚠️ Points d'Attention

1. **FCM Token**: Doit être envoyé lors du login par le frontend
2. **Doublons**: Vérifier qu'on ne crée pas plusieurs notifs pour la même ressource
3. **Followers**: Implémenter relation many-to-many users → followers
4. **Rate Limiting**: Éviter spam de notifications
5. **Soft Delete**: Considérer soft delete pour notifications
6. **Archivage**: Notifs anciennes peuvent être archivées

---

## 🎯 Résultat Final

Une fois implémenté, le flux complet sera:

```
1. Frontend: Utilisateur se connecte
   └─> Récupère FCM token
   └─> PUT /api/user/fcm-token (stocke token au backend)

2. Backend: Serviteur crée post
   └─> POST /api/posts
   └─> Récupère followers
   └─> Pour chaque follower:
       ├─> POST /api/notifications (crée en DB)
       └─> Firebase.send() (envoie FCM)

3. Frontend: Reçoit notification
   └─> onMessage / onMessageOpenedApp listener
   └─> Navigue vers le post via Routes.postDetail

4. Frontend: Utilisateur voit notification
   └─> GET /api/notifications (affiche liste)
   └─> PUT /api/notifications/{id}/read (marque lu)
```

**Tous les éléments frontend sont déjà implémentés et fonctionnels!** ✅

Il ne reste que le backend! 🚀
