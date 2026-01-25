# 📱 CHECKUP - Gestion des Notifications

## 📋 Résumé Exécutif

L'application utilise **Firebase Cloud Messaging (FCM)** pour les notifications push. La gestion actuelle est **partielle** et nécessite des améliorations.

---

## ✅ Ce qui fonctionne actuellement

### 1. **Configuration Firebase**
- ✅ Firebase est initialisé dans `main.dart`
- ✅ Handler pour les notifications en arrière-plan configuré
- ✅ Permissions demandées lors de la connexion (`login.dart`)

### 2. **Réception des notifications**
- ✅ Token FCM récupéré et envoyé au backend lors de la connexion
- ✅ Gestion des notifications quand l'app est fermée (`getInitialMessage`)
- ✅ Gestion des notifications quand l'app est ouverte (`onMessageOpenedApp`)

### 3. **Navigation depuis les notifications**
- ✅ Redirection vers les pages de détails selon le type :
  - `post` → `Routes.postDetail`
  - `event` → `Routes.eventDetail`
  - `ceremony` → `Routes.ceremonyDetail`

### 4. **Modèle de données**
- ✅ `NotificationModel` existe avec les champs :
  - `id`, `title`, `content`, `date`, `readed`, `type`
  - Méthode `getTile()` pour l'affichage

---

## ⚠️ Problèmes identifiés

### 1. **Pas de Provider pour les notifications**
- ❌ Aucun `NotificationProvider` dans les providers de l'app
- ❌ Pas de gestion d'état centralisée pour les notifications
- ❌ Pas de liste de notifications stockée localement

### 2. **Pas de page de liste des notifications**
- ❌ Aucune route définie pour une page de notifications
- ❌ Pas de page pour afficher l'historique des notifications
- ❌ Pas d'accès depuis le drawer ou l'app bar

### 3. **Pas de gestion des notifications en foreground**
- ❌ Pas de handler pour `FirebaseMessaging.onMessage` (notifications reçues quand l'app est ouverte)
- ❌ Pas d'affichage de notification locale quand l'app est active
- ❌ Les notifications peuvent être "perdues" si l'app est ouverte

### 4. **Modèle NotificationModel incomplet**
- ⚠️ Le parsing de la date est incorrect (`date: json['date']` devrait être `DateTime.parse()`)
- ⚠️ La méthode `getTile()` a un `onTap` vide (pas de navigation)
- ⚠️ Le style n'est pas moderne (couleurs hardcodées, pas de thème)

### 5. **Pas de marquage comme lu**
- ❌ Pas de méthode pour marquer une notification comme lue
- ❌ Pas de requête API pour mettre à jour le statut

### 6. **Pas de badge de compteur**
- ❌ Pas de compteur de notifications non lues
- ❌ Pas d'indicateur visuel dans l'UI

### 7. **Pas de requête API**
- ❌ Aucun fichier `notification_request.dart` dans `/requests`
- ❌ Pas de méthode pour récupérer les notifications depuis le backend

### 8. **Gestion du token FCM**
- ⚠️ Le token n'est envoyé qu'à la connexion
- ⚠️ Pas de mise à jour du token si celui-ci change
- ⚠️ Pas de gestion du refresh token

---

## 📊 Architecture actuelle

```
main.dart
├── Firebase.initializeApp() ✅
├── FirebaseMessaging.onBackgroundMessage() ✅
├── getInitialMessage() ✅ (app fermée)
└── onMessageOpenedApp() ✅ (app ouverte depuis notification)

login.dart
├── requestPermission() ✅
├── getToken() ✅
└── Envoi token au backend ✅

models/notification.dart
├── NotificationModel ✅
└── getTile() ⚠️ (incomplet)

❌ Pas de NotificationProvider
❌ Pas de NotificationRequest
❌ Pas de NotificationListPage
❌ Pas de handler onMessage (foreground)
```

---

## 🔧 Recommandations d'amélioration

### Priorité HAUTE 🔴

1. **Créer un NotificationProvider**
   - Gérer la liste des notifications
   - Méthodes : `getAll()`, `markAsRead()`, `getUnreadCount()`

2. **Créer NotificationRequest**
   - Endpoints : `GET /notifications`, `PUT /notifications/:id/read`

3. **Créer une page de liste des notifications**
   - Route : `Routes.notifications`
   - Affichage moderne avec le nouveau style de cartes
   - Pull-to-refresh

4. **Ajouter handler pour notifications foreground**
   - `FirebaseMessaging.onMessage` dans `main.dart`
   - Afficher une notification locale avec `flutter_local_notifications`

5. **Ajouter badge/compteur**
   - Badge dans le drawer ou app bar
   - Compteur de notifications non lues

### Priorité MOYENNE 🟡

6. **Améliorer NotificationModel**
   - Corriger le parsing de la date
   - Moderniser le style du `getTile()`
   - Ajouter navigation selon le type

7. **Gérer le refresh du token FCM**
   - Écouter `onTokenRefresh`
   - Mettre à jour le token côté backend

8. **Ajouter pagination**
   - Pour les listes de notifications longues

### Priorité BASSE 🟢

9. **Notifications groupées**
   - Grouper par type ou date

10. **Filtres**
    - Filtrer par type, lu/non lu

11. **Actions rapides**
    - Marquer tout comme lu
    - Supprimer des notifications

---

## 📝 Code manquant identifié

### Fichiers à créer :
- `lib/provider/notification.dart` ❌
- `lib/requests/notification_request.dart` ❌
- `lib/pages/notifications/list.dart` ❌
- `lib/pages/notifications/detail.dart` (optionnel)

### Modifications à faire :
- `lib/main.dart` : Ajouter handler `onMessage`
- `lib/models/notification.dart` : Corriger parsing date, moderniser style
- `lib/appstaticdata/routes.dart` : Ajouter route notifications
- `lib/components/drawer.dart` : Ajouter lien vers notifications avec badge

---

## 🎯 Conclusion

La base est présente (Firebase configuré, token envoyé, navigation basique), mais le système de notifications est **incomplet**. Il manque :
- La gestion d'état (Provider)
- L'affichage de la liste
- La gestion des notifications en foreground
- Les requêtes API
- Le marquage comme lu

**Score de complétude : 3/10** ⚠️


