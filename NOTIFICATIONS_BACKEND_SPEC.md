# Spécifications Backend: Système de Notifications

## Vue d'ensemble

Ce document décrit toutes les implémentations backend nécessaires pour le système de notifications de l'application AESD Buzz.

---

## 1. Table de Base de Données

### Table: `notifications`

```sql
CREATE TABLE notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    type ENUM('post', 'membership_request', 'donation', 'event') NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSON NULL,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_read_at (read_at),
    INDEX idx_created_at (created_at),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Migration Laravel:**

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->enum('type', ['post', 'membership_request', 'donation', 'event']);
            $table->string('title');
            $table->text('body');
            $table->json('data')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
            
            $table->index(['user_id', 'read_at']);
            $table->index('created_at');
        });
    }

    public function down()
    {
        Schema::dropIfExists('notifications');
    }
};
```

---

## 2. Model Eloquent

**Fichier:** `app/Models/Notification.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Notification extends Model
{
    protected $fillable = [
        'user_id',
        'type',
        'title',
        'body',
        'data',
        'read_at',
    ];

    protected $casts = [
        'data' => 'array',
        'read_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function markAsRead(): void
    {
        if (!$this->read_at) {
            $this->update(['read_at' => now()]);
        }
    }

    public function scopeUnread($query)
    {
        return $query->whereNull('read_at');
    }

    public function scopeForUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }
}
```

---

## 3. Controller

**Fichier:** `app/Http/Controllers/NotificationController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class NotificationController extends Controller
{
    /**
     * Liste des notifications de l'utilisateur connecté
     * GET /api/notifications
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $notifications = Notification::forUser($user->id)
            ->orderBy('created_at', 'desc')
            ->paginate(20);
        
        $unreadCount = Notification::forUser($user->id)
            ->unread()
            ->count();
        
        return response()->json([
            'success' => true,
            'unread_count' => $unreadCount,
            'notifications' => $notifications->items(),
            'pagination' => [
                'current_page' => $notifications->currentPage(),
                'total' => $notifications->total(),
                'per_page' => $notifications->perPage(),
            ],
        ]);
    }

    /**
     * Nombre de notifications non lues
     * GET /api/notifications/unread-count
     */
    public function unreadCount(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $count = Notification::forUser($user->id)
            ->unread()
            ->count();
        
        return response()->json([
            'success' => true,
            'unread_count' => $count,
        ]);
    }

    /**
     * Marquer une notification comme lue
     * POST /api/notifications/{id}/read
     */
    public function markAsRead(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        
        $notification = Notification::forUser($user->id)->findOrFail($id);
        $notification->markAsRead();
        
        return response()->json([
            'success' => true,
            'message' => 'Notification marquée comme lue',
        ]);
    }

    /**
     * Marquer toutes les notifications comme lues
     * POST /api/notifications/read-all
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        $user = $request->user();
        
        Notification::forUser($user->id)
            ->unread()
            ->update(['read_at' => now()]);
        
        return response()->json([
            'success' => true,
            'message' => 'Toutes les notifications marquées comme lues',
        ]);
    }

    /**
     * Supprimer une notification
     * DELETE /api/notifications/{id}
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        
        $notification = Notification::forUser($user->id)->findOrFail($id);
        $notification->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Notification supprimée',
        ]);
    }
}
```

---

## 4. Routes API

**Fichier:** `routes/api.php`

```php
use App\Http\Controllers\NotificationController;

Route::middleware('auth:sanctum')->group(function () {
    // Notifications
    Route::get('notifications', [NotificationController::class, 'index']);
    Route::get('notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::post('notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    Route::delete('notifications/{id}', [NotificationController::class, 'destroy']);
});
```

---

## 5. Service de Notifications

**Fichier:** `app/Services/NotificationService.php`

```php
<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Support\Collection;

class NotificationService
{
    /**
     * Créer une notification pour un utilisateur
     */
    public function create(
        int $userId,
        string $type,
        string $title,
        string $body,
        ?array $data = null
    ): Notification {
        return Notification::create([
            'user_id' => $userId,
            'type' => $type,
            'title' => $title,
            'body' => $body,
            'data' => $data,
        ]);
    }

    /**
     * Créer des notifications pour plusieurs utilisateurs
     */
    public function createForMany(
        Collection $userIds,
        string $type,
        string $title,
        string $body,
        ?array $data = null
    ): void {
        $notifications = $userIds->map(function ($userId) use ($type, $title, $body, $data) {
            return [
                'user_id' => $userId,
                'type' => $type,
                'title' => $title,
                'body' => $body,
                'data' => $data ? json_encode($data) : null,
                'created_at' => now(),
                'updated_at' => now(),
            ];
        });

        Notification::insert($notifications->toArray());
    }

    /**
     * Envoyer une notification push FCM (optionnel)
     */
    public function sendPushNotification(User $user, string $title, string $body, ?array $data = null): void
    {
        if (!$user->fcm_token) {
            return;
        }

        // TODO: Implémenter FCM si nécessaire
        // Utiliser firebase/php-jwt ou kreait/laravel-fcm
    }
}
```

---

## 6. Triggers de Notifications

### A. Notification de Nouveau Post

**Fichier:** `app/Http/Controllers/PostController.php` (ou équivalent)

> [!IMPORTANT]
> **Le champ `data` doit TOUJOURS contenir `post_id` pour que la navigation fonctionne !**

```php
use App\Services\NotificationService;
use Illuminate\Support\Str;

public function store(Request $request)
{
    // ... validation et création du post ...
    
    $post = Post::create($validated);
    
    // TRIGGER: Notifier les fidèles de l'église
    if ($post->church_id) {
        $church = Church::with('members')->find($post->church_id);
        $memberIds = $church->members->pluck('id');
        
        $notificationService = new NotificationService();
        $notificationService->createForMany(
            $memberIds,
            'post',  // ← Type DOIT être 'post'
            "Nouveau post de {$request->user()->name}",
            Str::limit($post->content, 100),
            [
                'post_id' => $post->id,  // ← CRITIQUE: post_id requis pour navigation
                'sender_name' => $request->user()->name,
            ]
        );
    }
    
    return response()->json([
        'success' => true,
        'data' => $post,
    ]);
}
```

### B. Notification de Demande d'Adhésion

**Fichier:** `app/Http/Controllers/MembershipRequestController.php`

> [!WARNING]
> **Le type `membership_request` n'a pas de navigation automatique.** Vous pouvez afficher un snackbar ou rediriger vers la page des demandes.

```php
use App\Services\NotificationService;

public function store(Request $request)
{
    // ... validation et création de la demande ...
    
    $membershipRequest = MembershipRequest::create([
        'user_id' => $request->user()->id,
        'church_id' => $request->church_id,
        'state' => 'pending',
    ]);
    
    // TRIGGER: Notifier le propriétaire de l'église
    $church = Church::with('owner')->find($request->church_id);
    
    if ($church && $church->owner_id) {
        $notificationService = new NotificationService();
        $notificationService->create(
            $church->owner_id,
            'membership_request',  // ← Type membership_request
            "Nouvelle demande d'adhésion",
            "{$request->user()->name} souhaite rejoindre {$church->name}",
            [
                'request_id' => $membershipRequest->id,
                'user_id' => $request->user()->id,
                'church_id' => $church->id,
            ]
        );
    }
    
    return response()->json([
        'success' => true,
        'message' => "Demande d'adhésion envoyée",
    ]);
}
```

### C. Notification de Don (Optionnel)

```php
public function storeDonation(Request $request)
{
    // ... création du don ...
    
    $donation = Donation::create($validated);
    
    // TRIGGER: Notifier le destinataire
    $notificationService = new NotificationService();
    $notificationService->create(
        $donation->recipient_user_id,
        'donation',  // Ce type n'a pas de page spécifique
        "Nouveau don reçu",
        "Vous avez reçu un don de {$donation->amount} XOF",
        [
            'donation_id' => $donation->id,
            'amount' => $donation->amount,
        ]
    );
}
```

### D. Types de Notifications avec Navigation

| Type | Navigation | Champ `data` requis |
|------|-----------|---------------------|
| `post` | ✅ Détail du post | `post_id` |
| `event` | ✅ Détail événement | `post_id` (alias pour event_id) |
| `ceremony` | ✅ Détail cérémonie | `post_id` (alias pour ceremony_id) |
| `membership_request` | ❌ Snackbar uniquement | - |
| `donation` | ❌ Snackbar uniquement | - |

---

## 7. Format de Réponse Attendu par le Frontend

### GET /api/notifications

```json
{
  "success": true,
  "unread_count": 5,
  "notifications": [
    {
      "id": 1,
      "user_id": 123,
      "type": "post",
      "title": "Nouveau post de Pastor John",
      "body": "Lorem ipsum dolor sit amet...",
      "data": {
        "post_id": 456,
        "sender_name": "Pastor John"
      },
      "read_at": null,
      "created_at": "2026-02-16T10:00:00.000000Z",
      "updated_at": "2026-02-16T10:00:00.000000Z"
    },
    {
      "id": 2,
      "user_id": 123,
      "type": "membership_request",
      "title": "Nouvelle demande d'adhésion",
      "body": "Marie Dupont souhaite rejoindre Église Baptiste",
      "data": {
        "request_id": 789,
        "user_id": 234,
        "church_id": 567
      },
      "read_at": "2026-02-16T11:30:00.000000Z",
      "created_at": "2026-02-16T09:00:00.000000Z",
      "updated_at": "2026-02-16T11:30:00.000000Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total": 25,
    "per_page": 20
  }
}
```

---

## 8. Tests API (Exemples)

### Créer une notification de test

```bash
# Via Tinker
php artisan tinker

$notification = \App\Models\Notification::create([
    'user_id' => 1,
    'type' => 'post',
    'title' => 'Test notification',
    'body' => 'Ceci est un test',
    'data' => ['post_id' => 999],
]);
```

### Tester les endpoints

```bash
# Liste des notifications
curl -X GET "http://localhost:8000/api/notifications" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Compteur non lues
curl -X GET "http://localhost:8000/api/notifications/unread-count" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Marquer comme lue
curl -X POST "http://localhost:8000/api/notifications/1/read" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 9. Intégration FCM (Optionnel)

Si vous souhaitez implémenter les notifications push:

### Installation

```bash
composer require kreait/laravel-firebase
```

### Configuration

1. Ajouter `fcm_token` dans la table `users`:

```sql
ALTER TABLE users ADD COLUMN fcm_token VARCHAR(255) NULL;
```

2. Créer un endpoint pour mettre à jour le token:

```php
// POST /api/users/fcm-token
public function updateFcmToken(Request $request)
{
    $request->validate(['token' => 'required|string']);
    
    $request->user()->update([
        'fcm_token' => $request->token,
    ]);
    
    return response()->json(['success' => true]);
}
```

---

## 10. Checklist d'Implémentation

- [ ] Créer la migration `notifications`
- [ ] Créer le model `Notification`
- [ ] Créer le controller `NotificationController`
- [ ] Ajouter les routes dans `api.php`
- [ ] Créer le service `NotificationService`
- [ ] Ajouter trigger dans `PostController`
- [ ] Ajouter trigger dans `MembershipRequestController`
- [ ] (Optionnel) Ajouter trigger dans `DonationController`
- [ ] Tester les endpoints avec Postman
- [ ] (Optionnel) Configurer FCM

---

## Questions / Support

Si vous avez des questions sur l'implémentation, contactez l'équipe frontend.

**Frontend déjà implémenté:**
- ✅ Service de notifications Flutter
- ✅ Page liste des notifications
- ✅ Provider pour gérer l'état

**Il ne manque que le backend !** 🚀
