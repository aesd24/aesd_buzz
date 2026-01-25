# 🔌 Requirements Backend pour les Notifications

## 📋 Informations nécessaires du Backend

Pour rendre le système de notifications **complètement fonctionnel**, voici ce dont j'ai besoin :

---

## ✅ Ce qui est déjà en place (Frontend)

### Configuration Firebase
- ✅ Firebase initialisé
- ✅ Token FCM récupéré et envoyé au backend lors de la connexion
- ✅ Handler pour notifications en arrière-plan
- ✅ Navigation basique depuis les notifications

### Structure API identifiée
- Base URL : `https://monapi.eglisesetserviteursdedieu.com/api/`
- Pattern d'endpoints : `baseRoute` ou `baseRoute/id`
- Authentification : Token dans header `Authorization`

---

## ❓ Informations nécessaires du Backend

### 1. **Endpoints API à confirmer**

#### A. Récupérer la liste des notifications
```
GET /notifications
```
**Réponse attendue :**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Titre de la notification",
      "content": "Contenu de la notification",
      "date": "2025-01-15T10:30:00Z",  // Format ISO 8601
      "readed": 0,  // 0 = non lu, 1 = lu
      "notificationType": "post"  // ou "event", "ceremony", etc.
    }
  ],
  "unread_count": 5  // Optionnel mais recommandé
}
```

#### B. Marquer une notification comme lue
```
PUT /notifications/{id}/read
ou
POST /notifications/{id}/read
```
**Réponse attendue :**
```json
{
  "message": "Notification marquée comme lue",
  "data": {
    "id": 1,
    "readed": 1
  }
}
```

#### C. Marquer toutes les notifications comme lues
```
PUT /notifications/read-all
ou
POST /notifications/read-all
```
**Réponse attendue :**
```json
{
  "message": "Toutes les notifications ont été marquées comme lues",
  "count": 5
}
```

#### D. Compteur de notifications non lues
```
GET /notifications/unread-count
```
**Réponse attendue :**
```json
{
  "count": 5
}
```

---

### 2. **Structure des notifications Push (FCM)**

Le backend doit envoyer les notifications avec cette structure :

```json
{
  "notification": {
    "title": "Titre de la notification",
    "body": "Contenu de la notification"
  },
  "data": {
    "type": "post",  // "post", "event", "ceremony", "news", etc.
    "id": "123"  // ID de l'élément concerné
  }
}
```

**Types supportés actuellement :**
- `post` → Redirige vers `Routes.postDetail`
- `event` → Redirige vers `Routes.eventDetail`
- `ceremony` → Redirige vers `Routes.ceremonyDetail`

**Types à ajouter (optionnel) :**
- `news` → Redirige vers `Routes.newsDetail`
- `forum` → Redirige vers `Routes.subject`
- `testimony` → Redirige vers `Routes.testimonyDetail`
- `church` → Redirige vers `Routes.churchDetail`

---

### 3. **Format de date**

**Question importante :** Quel format de date utilise le backend ?
- Format ISO 8601 : `"2025-01-15T10:30:00Z"` ✅ (recommandé)
- Format timestamp : `1705315800`
- Format string : `"2025-01-15 10:30:00"`

**Actuellement dans le code :**
```dart
date: json['date']  // ⚠️ Problème : pas de parsing
```

**À corriger selon le format backend :**
```dart
// Si ISO 8601
date: DateTime.parse(json['date'])

// Si timestamp
date: DateTime.fromMillisecondsSinceEpoch(json['date'] * 1000)

// Si string custom
date: DateFormat('yyyy-MM-dd HH:mm:ss').parse(json['date'])
```

---

### 4. **Pagination (optionnel mais recommandé)**

Si beaucoup de notifications, pagination nécessaire :

```
GET /notifications?page=1&per_page=20
```

**Réponse avec pagination :**
```json
{
  "data": [...],
  "current_page": 1,
  "total_pages": 5,
  "per_page": 20,
  "total": 100
}
```

---

### 5. **Filtres (optionnel)**

```
GET /notifications?type=post&readed=0
```

---

## 🎯 Checklist Backend

### Minimum requis pour fonctionnalité de base :
- [ ] Endpoint `GET /notifications` qui retourne la liste
- [ ] Endpoint `PUT/POST /notifications/{id}/read` pour marquer comme lu
- [ ] Format de date confirmé (ISO 8601 recommandé)
- [ ] Structure de réponse JSON standardisée

### Recommandé pour meilleure UX :
- [ ] Endpoint `GET /notifications/unread-count` pour le badge
- [ ] Endpoint `PUT/POST /notifications/read-all` pour marquer tout
- [ ] Pagination sur `GET /notifications`
- [ ] Filtres par type et statut lu/non lu

### Bonus :
- [ ] Webhook pour notifier en temps réel (WebSocket)
- [ ] Groupement de notifications similaires
- [ ] Suppression de notifications

---

## 📝 Code Frontend à créer (une fois les endpoints confirmés)

### Fichiers à créer :
1. `lib/requests/notification_request.dart` - Requêtes API
2. `lib/provider/notification.dart` - Gestion d'état
3. `lib/pages/notifications/list.dart` - Page de liste
4. Modifications dans `lib/main.dart` - Handler foreground

### Structure du NotificationRequest (exemple) :
```dart
class NotificationRequest extends DioClient {
  final String baseRoute = "notifications";
  
  Future getAll({int? page}) async {
    final client = await getApiClient();
    return client.get(baseRoute, queryParameters: page != null ? {"page": page} : null);
  }
  
  Future markAsRead(int id) async {
    final client = await getApiClient();
    return client.put('$baseRoute/$id/read');
  }
  
  Future markAllAsRead() async {
    final client = await getApiClient();
    return client.put('$baseRoute/read-all');
  }
  
  Future getUnreadCount() async {
    final client = await getApiClient();
    return client.get('$baseRoute/unread-count');
  }
}
```

---

## ❓ Questions pour le Backend

1. **Quel est le nom exact de l'endpoint pour les notifications ?**
   - `/notifications` ?
   - `/user/notifications` ?
   - Autre ?

2. **Quel format de date est utilisé ?**
   - ISO 8601 ?
   - Timestamp ?
   - Format custom ?

3. **Le champ `readed` est-il 0/1 ou true/false ?**
   - Actuellement le code attend 0/1

4. **Y a-t-il déjà un endpoint pour le compteur de non lus ?**

5. **Y a-t-il pagination ? Si oui, quel format ?**

6. **Quels sont tous les types de notifications possibles ?**
   - Pour gérer la navigation correctement

---

## ✅ Conclusion

**Pour rendre le système fonctionnel, j'ai besoin de :**

1. ✅ **Confirmation des endpoints** (nom exact, méthode HTTP)
2. ✅ **Format de date** utilisé
3. ✅ **Structure exacte de la réponse JSON**
4. ✅ **Types de notifications** supportés

**Une fois ces informations fournies, je peux implémenter :**
- ✅ Le NotificationRequest
- ✅ Le NotificationProvider
- ✅ La page de liste moderne
- ✅ Le badge/compteur
- ✅ Le marquage comme lu
- ✅ La gestion foreground

**Temps estimé d'implémentation :** 2-3 heures une fois les infos backend confirmées


