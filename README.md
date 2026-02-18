# 📱 AESD Buzz - Application Mobile Flutter

## 🎯 Vue d'Ensemble du Projet

**AESD Buzz** est une application mobile Flutter complète pour la communauté des Églises et Serviteurs de Dieu. Elle offre une plateforme sociale et spirituelle avec streaming en direct, système de dons, quiz bibliques, forums, et bien plus.

### Informations Clés
- **Nom du projet**: aesd
- **Description**: New aesd application based on Buzz templates
- **Version actuelle**: 1.0.0+20
- **Langage principal**: Dart/Flutter
- **SDK Flutter**: >=3.7.0-0 <4.0.0
- **API Backend**: https://monapi.eglisesetserviteursdedieu.com/api

---

## 📚 Table des Matières

1. [Architecture du Projet](#-architecture-du-projet)
2. [Structure des Fichiers](#-structure-des-fichiers)
3. [Technologies et Dépendances](#-technologies-et-dépendances)
4. [Configuration et Installation](#-configuration-et-installation)
5. [Fonctionnalités Principales](#-fonctionnalités-principales)
6. [Gestion d'État](#-gestion-détat)
7. [Services](#-services)
8. [Modèles de Données](#-modèles-de-données)
9. [Navigation et Routes](#-navigation-et-routes)
10. [Build et Déploiement](#-build-et-déploiement)
11. [Documentation Supplémentaire](#-documentation-supplémentaire)

---

## 🏗️ Architecture du Projet

L'application suit une architecture **Provider-based** avec séparation claire des responsabilités:

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                              │
│  (Pages, Components, Widgets)                                │
└──────────────────┬────────────────────────────────────────────┘
                   │
┌──────────────────▼────────────────────────────────────────────┐
│                    Provider Layer                              │
│  (State Management - 18 Providers)                            │
└──────────────────┬────────────────────────────────────────────┘
                   │
┌──────────────────▼────────────────────────────────────────────┐
│                    Service Layer                               │
│  (Business Logic, API Calls, External Services)               │
└──────────────────┬────────────────────────────────────────────┘
                   │
┌──────────────────▼────────────────────────────────────────────┐
│                    Data Layer                                  │
│  (Models, Requests, Storage)                                  │
└───────────────────────────────────────────────────────────────┘
```

### Principes d'Architecture

- **Séparation des préoccupations**: UI, logique métier, et données sont séparés
- **State Management centralisé**: Utilisation de Provider pour gérer l'état global
- **Services réutilisables**: Logique métier encapsulée dans des services
- **Modèles typés**: Tous les objets de données ont des modèles Dart définis

---

## 📂 Structure des Fichiers

### Structure Racine

```
aesd_buzz/
├── 📁 android/                    # Code natif Android
│   ├── app/
│   │   ├── build.gradle.kts      # Configuration build Android
│   │   ├── google-services.json  # Config Firebase
│   │   └── upload-keystore.jks   # Clé de signature (SENSIBLE)
│   ├── build.gradle.kts
│   ├── settings.gradle.kts
│   └── key.properties            # Props de signature (SENSIBLE)
│
├── 📁 ios/                        # Code natif iOS
│
├── 📁 assets/                     # Ressources statiques
│   ├── fonts/                    # Police Gilroy
│   ├── icons/                    # Icônes d'app
│   ├── images/                   # Images
│   ├── illustrations/            # Illustrations
│   └── locales/                  # Traductions (ar.json, en.json)
│
├── 📁 lib/                        # Code source Dart principal
│   ├── 📁 appstaticdata/         # Données statiques app
│   │   ├── colorfile.dart        # Palette de couleurs
│   │   ├── dictionnary.dart      # Dictionnaire de l'app
│   │   ├── routes.dart           # Définitions des routes
│   │   └── staticdata.dart       # Données statiques
│   │
│   ├── 📁 components/             # Widgets réutilisables (17 fichiers)
│   │   ├── bottom_sheets.dart
│   │   ├── buttons.dart
│   │   ├── certification_banner.dart
│   │   ├── church_banner.dart
│   │   ├── containers.dart
│   │   ├── divider.dart
│   │   ├── drawer.dart
│   │   ├── fields.dart
│   │   ├── icon.dart
│   │   ├── image_container.dart
│   │   ├── image_viewer.dart
│   │   ├── loader.dart
│   │   ├── modal.dart
│   │   ├── not_found.dart
│   │   ├── placeholders.dart
│   │   ├── structure.dart
│   │   └── tiles.dart
│   │
│   ├── 📁 functions/              # Fonctions utilitaires (5 fichiers)
│   │   ├── camera_functions.dart # Gestion caméra/photos
│   │   ├── file_functions.dart   # Manipulation fichiers
│   │   ├── formatteurs.dart      # Formatage dates, nombres
│   │   ├── launcher.dart         # Ouverture URLs
│   │   └── utilities.dart        # Utilitaires généraux
│   │
│   ├── 📁 middleware/             # Middlewares (1 fichier)
│   │   └── auth_middleware.dart  # Protection routes authentifiées
│   │
│   ├── 📁 models/                 # Modèles de données (28 fichiers)
│   │   ├── ceremony.dart
│   │   ├── church_model.dart
│   │   ├── comment.dart
│   │   ├── donation_model.dart
│   │   ├── donation_transaction_model.dart
│   │   ├── event.dart
│   │   ├── forum_model.dart
│   │   ├── live_model.dart
│   │   ├── news.dart
│   │   ├── notification.dart
│   │   ├── post_model.dart
│   │   ├── quiz_model.dart
│   │   ├── user_model.dart
│   │   ├── wallet_model.dart
│   │   └── ... (14 autres modèles)
│   │
│   ├── 📁 pages/                  # Écrans de l'application (70 fichiers)
│   │   ├── 📁 auth/              # Authentification (8 pages)
│   │   │   ├── login.dart
│   │   │   ├── register.dart
│   │   │   ├── forgot_password.dart
│   │   │   └── ...
│   │   ├── 📁 dashboard/         # Tableau de bord (8 pages)
│   │   ├── 📁 live/              # Streaming live (3 pages)
│   │   ├── 📁 wallet/            # Portefeuille/Dons (6 pages)
│   │   │   ├── wallet_page.dart
│   │   │   ├── donation_page.dart
│   │   │   ├── send_money_page.dart
│   │   │   ├── withdraw_page.dart
│   │   │   └── ...
│   │   ├── 📁 social/            # Réseau social (18 pages)
│   │   ├── 📁 quiz/              # Quiz bibliques (7 pages)
│   │   ├── 📁 forum/             # Forums (2 pages)
│   │   ├── 📁 ceremonies/        # Cérémonies (4 pages)
│   │   ├── 📁 events/            # Événements (3 pages)
│   │   ├── 📁 testimony/         # Témoignages (3 pages)
│   │   ├── 📁 notifications/     # Notifications (1 page)
│   │   ├── 📁 user/              # Profil utilisateur (2 pages)
│   │   └── home.dart             # Page d'accueil
│   │
│   ├── 📁 provider/               # Providers (18 fichiers)
│   │   ├── auth.dart             # Authentification
│   │   ├── ceremonies.dart       # Gestion cérémonies
│   │   ├── church.dart           # Gestion églises
│   │   ├── cinetpay.dart         # Paiements CinetPay
│   │   ├── event.dart            # Gestion événements
│   │   ├── forum.dart            # Gestion forums
│   │   ├── live_provider.dart    # Streaming LiveKit
│   │   ├── news.dart             # Actualités
│   │   ├── notification.dart     # Notifications
│   │   ├── post.dart             # Posts sociaux
│   │   ├── program.dart          # Programmes
│   │   ├── proviercolors.dart    # Thème clair/sombre
│   │   ├── quiz.dart             # Quiz
│   │   ├── servant.dart          # Serviteurs/Pasteurs
│   │   ├── singer.dart           # Chanteurs
│   │   ├── testimony.dart        # Témoignages
│   │   ├── user.dart             # Utilisateur
│   │   └── wallet_provider.dart  # Portefeuille
│   │
│   ├── 📁 requests/               # Requêtes API (16 fichiers)
│   │   ├── auth_requests.dart
│   │   ├── church_requests.dart
│   │   ├── donation_requests.dart
│   │   ├── event_requests.dart
│   │   ├── live_requests.dart
│   │   ├── post_requests.dart
│   │   ├── wallet_requests.dart
│   │   └── ... (9 autres)
│   │
│   ├── 📁 schemas/                # Schémas de validation (2 fichiers)
│   │
│   ├── 📁 services/               # Services (9 fichiers)
│   │   ├── dio_service.dart              # Client HTTP Dio
│   │   ├── donation_service.dart         # Service dons
│   │   ├── donation_wallet_service.dart  # Portefeuille dons
│   │   ├── livekit_service.dart          # Service LiveKit (14KB)
│   │   ├── message.dart                  # Messages/Toasts
│   │   ├── storage_auth_token_session.dart  # JWT Storage
│   │   ├── un_expired_cache.dart         # Cache
│   │   ├── wallet_service.dart           # Service portefeuille
│   │   └── withdrawal_service.dart       # Retraits
│   │
│   └── main.dart                  # Point d'entrée (275 lignes)
│
├── 📁 test/                       # Tests unitaires
│
├── 📁 web/                        # Support web (optionnel)
│
├── 📄 .env                        # Variables d'environnement (SENSIBLE)
├── 📄 .env.example                # Template variables env
├── 📄 pubspec.yaml                # Dépendances Flutter
├── 📄 analysis_options.yaml       # Config linter
│
└── 📄 Documentation/               # Fichiers de documentation
    ├── API_SWAGGER_ANALYSIS.md           # Analyse API Swagger
    ├── BACKEND_DONATIONS_SPEC.md         # Spéc API donations
    ├── BACKEND_WALLET_API_SPECIFICATION.md
    ├── GUIDE_CONFIGURATION_CINETPAY.md   # Config paiements
    ├── GUIDE_RECUPERATION_CLE_SIGNATURE.md
    ├── README_NOTIFICATIONS.md           # Guide notifications
    ├── TESTING_GUIDE_NOTIFICATIONS.md
    └── ... (autres docs)
```

### Points Importants à Noter

- **⚠️ Fichiers sensibles** (NE PAS COMMITER):
  - `.env` - Clés API CinetPay
  - `android/key.properties` - Props signature Android
  - `android/app/upload-keystore.jks` - Keystore Android
  
- **Documentation riche**: Plusieurs guides en Markdown disponibles

---

## 🛠️ Technologies et Dépendances

### Framework Principal

- **Flutter SDK**: >=3.7.0-0 <4.0.0
- **Dart**: Inclus avec Flutter

### Dépendances Principales (pubspec.yaml)

#### State Management & Navigation
```yaml
get: ^4.6.5              # Navigation et state management
provider: ^6.0.5         # State management principal
```

#### UI/UX
```yaml
google_fonts: ^6.2.1             # Polices Google
flutter_svg: ^2.0.6              # Support SVG
carousel_slider: ^5.1.1          # Carrousels
shimmer: ^3.0.0                  # Effets chargement
lottie: ^3.3.1                   # Animations Lottie
accordion: ^2.6.0                # Accordéons
photo_view: ^0.15.0              # Visionneuse photos
```

#### Réseau & API
```yaml
http: ^1.0.0                     # Client HTTP
dio: ^5.8.0+1                    # Client HTTP avancé
fast_cached_network_image: ^1.3.3+5  # Cache images
```

#### Media & Fichiers
```yaml
image_picker: ^1.1.2             # Sélection photos
file_picker: ^10.2.0             # Sélection fichiers
path_provider: ^2.1.5            # Chemins système
record: ^6.1.1                   # Enregistrement audio
audioplayers: ^6.5.0             # Lecture audio
video_player: ^2.0.0             # Lecture vidéo
chewie: ^1.8.3                   # Player vidéo UI
```

#### Firebase & Notifications
```yaml
firebase_core: ^3.13.0           # Core Firebase
firebase_messaging: ^15.2.5      # Push notifications FCM
device_info_plus: ^9.0.0         # Info appareil
```

#### Live Streaming
```yaml
livekit_client: ^2.3.1+hotfix.1  # SDK LiveKit
permission_handler: ^11.3.1      # Permissions caméra/micro
wakelock_plus: ^1.2.8            # Empêcher verrouillage écran
```

#### Paiements
```yaml
cinetpay: ^1.0.8                 # SDK CinetPay (Côte d'Ivoire)
flutter_dotenv: ^5.1.0           # Variables d'environnement
```

#### Stockage & Sécurité
```yaml
shared_preferences: ^2.5.3       # Préférences locales
flutter_secure_storage: ^9.2.4   # Stockage sécurisé (JWT)
```

#### Autres
```yaml
intl: any                        # Internationalisation
url_launcher: ^6.1.1             # Ouverture URLs
loading_overlay: ^0.4.3          # Overlays chargement
otp_text_field: ^1.1.3           # Champs OTP
date_field: ^6.0.0               # Sélecteurs date
```

---

## ⚙️ Configuration et Installation

### Prérequis

1. **Flutter SDK** >= 3.7.0
2. **Android Studio** ou **Xcode** (selon plateforme)
3. **Un éditeur de code** (VS Code recommandé)
4. **Git**

### Installation Étape par Étape

#### 1. Cloner le Dépôt

```bash
git clone <repository-url>
cd aesd_buzz
```

#### 2. Installer les Dépendances

```bash
flutter pub get
```

#### 3. Configurer les Variables d'Environnement

Copier `.env.example` vers `.env`:

```bash
cp .env.example .env
```

Éditer `.env` avec vos vraies clés:

```env
# CinetPay Configuration
CINETPAY_API_KEY=votre_clé_api
CINETPAY_SITE_ID=votre_site_id
CINETPAY_NOTIFY_URL=https://monapi.eglisesetserviteursdedieu.com/api/donations/webhook
CINETPAY_RETURN_URL=aesd://donation/success

# Backend API
API_BASE_URL=https://monapi.eglisesetserviteursdedieu.com/api
```

#### 4. Configuration Firebase

- Placer `google-services.json` dans `android/app/`
- Placer `GoogleService-Info.plist` dans `ios/Runner/` (si iOS)

#### 5. Configuration Signature Android (Release)

Créer `android/key.properties`:

```properties
storePassword=<votre_mot_de_passe>
keyPassword=<votre_mot_de_passe_clé>
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ Important**: Ne JAMAIS commit ce fichier dans Git!

#### 6. Vérifier l'Installation

```bash
flutter doctor -v
```

#### 7. Lancer l'Application

```bash
# Mode debug
flutter run

# Mode release (Android)
flutter run --release

# Build APK
flutter build apk --release

# Build App Bundle (Google Play)
flutter build appbundle --release
```

---

## 🎨 Fonctionnalités Principales

### 1. Authentification 🔐
- Inscription/Connexion
- Récupération mot de passe
- Vérification OTP
- Gestion profil utilisateur
- JWT Token storage sécurisé

### 2. Églises & Communautés ⛪
- Création d'églises
- Validation d'églises (système de bannière)
- Abonnement aux églises
- Photos d'églises
- Demandes d'adhésion

### 3. Réseau Social 📱
- Création de posts (texte, image, vidéo)
- Likes et commentaires
- Timeline personnalisée
- Profils serviteurs/pasteurs
- Abonnement aux serviteurs

### 4. Streaming Live en Direct 📹
- Diffusion live via **LiveKit**
- Enregistrement automatique des streams
- Chat en direct
- Permissions caméra/micro
- Support multi-plateforme

### 5. Système de Dons & Portefeuille 💰
- Portefeuille intégré
- Dons aux églises/serviteurs
- Paiements via **CinetPay**
- Retraits
- Historique transactions
- Balance églises vs utilisateurs réguliers

### 6. Quiz Bibliques 📖
- Création de quiz
- Participation quiz
- Classements
- Résultats et statistiques

### 7. Forum & Discussions 💬
- Création de sujets
- Commentaires
- Questions/Réponses

### 8. Événements & Cérémonies 📅
- Création événements
- Détails cérémonies
- Programmes journaliers
- Calendrier

### 9. Témoignages ✨
- Partage de témoignages
- Lecture témoignages

### 10. Notifications Push 🔔
- Firebase Cloud Messaging (FCM)
- Notifications temps réel
- Navigation deep linking
- Gestion foreground/background

---

## 🔄 Gestion d'État

L'application utilise **Provider** comme solution principale de state management.

### Liste des 18 Providers

| Provider | Fichier | Responsabilité |
|----------|---------|----------------|
| `ColorNotifire` | `proviercolors.dart` | Thème clair/sombre |
| `Auth` | `auth.dart` | Authentification utilisateur |
| `UserProvider` | `user.dart` | Profil utilisateur |
| `Church` | `church.dart` | Gestion églises |
| `PostProvider` | `post.dart` | Posts sociaux |
| `Forum` | `forum.dart` | Forums discussions |
| `Quiz` | `quiz.dart` | Quiz bibliques |
| `Event` | `event.dart` | Événements |
| `News` | `news.dart` | Actualités |
| `NotificationProvider` | `notification.dart` | Notifications |
| `LiveProvider` | `live_provider.dart` | Streaming LiveKit |
| `Servant` | `servant.dart` | Serviteurs/Pasteurs |
| `Singer` | `singer.dart` | Chanteurs |
| `Testimony` | `testimony.dart` | Témoignages |
| `Ceremonies` | `ceremonies.dart` | Cérémonies |
| `ProgramProvider` | `program.dart` | Programmes |
| `CinetPay` | `cinetpay.dart` | Paiements |
| `WalletProvider` | `wallet_provider.dart` | Portefeuille |

### Initialisation (main.dart)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => ColorNotifire()),
    ChangeNotifierProvider(create: (context) => Auth()),
    // ... 16 autres providers
  ],
  child: GetMaterialApp(...)
)
```

### Utilisation dans les Widgets

```dart
// Lire l'état
final auth = Provider.of<Auth>(context);

// Ou avec Consumer
Consumer<Auth>(
  builder: (context, auth, child) {
    return Text(auth.user.name);
  }
)

// Utilisation sans rebuild
context.read<PostProvider>().createPost(data);
```

---

## 🌐 Services

### 1. DioService (`dio_service.dart`)
Client HTTP configuré avec intercepteurs

### 2. LiveKitService (`livekit_service.dart`) - 14KB
- Gestion complète LiveKit
- Création de rooms
- Tokens d'accès
- Enregistrements automatiques

### 3. WalletService (`wallet_service.dart`)
- API portefeuille
- Balance utilisateur
- Transactions

### 4. DonationService (`donation_service.dart`)
- Création dons
- Historique dons

### 5. DonationWalletService (`donation_wallet_service.dart`)
- Balance dons églises

### 6. WithdrawalService (`withdrawal_service.dart`)
- Demandes de retrait

### 7. MessageService (`message.dart`)
- Affichage toasts/snackbars
- Messages erreur/succès

### 8. StorageAuthTokenSession (`storage_auth_token_session.dart`)
- Stockage sécurisé JWT
- Gestion session

### 9. UnExpiredCache (`un_expired_cache.dart`)
- Cache avec expiration

---

## 📊 Modèles de Données

28 modèles Dart définis, incluant:

### Principaux Modèles

- **UserModel**: Utilisateur
- **ChurchModel**: Église
- **PostModel**: Post social
- **EventModel**: Événement
- **CeremonyModel**: Cérémonie
- **LiveModel**: Stream live
- **QuizModel**: Quiz
- **ForumModel**: Sujet forum
- **NotificationModel**: Notification
- **DonationModel**: Don
- **DonationTransactionModel**: Transaction don
- **WalletModel**: Portefeuille
- **CommentModel**: Commentaire
- **TestimonyModel**: Témoignage

### Structure Type d'un Modèle

```dart
class PostModel {
  final int id;
  final String title;
  final String content;
  final int userId;
  final DateTime createdAt;
  
  PostModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

---

## 🗺️ Navigation et Routes

L'application utilise **GetX** pour la navigation.

### Fichiers Clés

- `appstaticdata/routes.dart` - Définitions routes

### Routes Principales

```dart
class Routes {
  static const initial = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const postDetail = '/post/:id';
  static const eventDetail = '/event/:id';
  static const ceremonyDetail = '/ceremony/:id';
  static const walletPage = '/wallet';
  static const donationPage = '/donation';
  static const liveStream = '/live/:id';
  // ... 50+ autres routes
}
```

### Navigation

```dart
// Navigation simple
Get.toNamed(Routes.home);

// Avec arguments
Get.toNamed(
  Routes.postDetail, 
  arguments: {'postId': 123}
);

// Retour
Get.back();
```

---

## 🔨 Build et Déploiement

### Build Android (Debug)

```bash
flutter build apk --debug
```

### Build Android (Release)

```bash
# APK
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release
```

**Fichiers générés**:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### Build iOS

```bash
flutter build ios --release
```

### Configuration de Signature

#### Android

Le fichier `android/app/build.gradle.kts` est configuré pour:
- **Debug**: Signature automatique
- **Release**: Utilise `upload-keystore.jks`

**Keystore actuel**: `android/app/upload-keystore.jks`

**⚠️ Important**: 
- Ce keystore doit être conservé précieusement
- Perdu = impossibilité de mettre à jour l'app sur Google Play
- Voir `GUIDE_RECUPERATION_CLE_SIGNATURE.md` pour détails

### Déploiement

#### Google Play Console

1. Build App Bundle: `flutter build appbundle --release`
2. Aller sur [Google Play Console](https://play.google.com/console)
3. Créer une nouvelle release
4. Upload `app-release.aab`
5. Remplir changelog
6. Soumettre pour review

#### TestFlight (iOS)

1. Build iOS: `flutter build ios --release`
2. Ouvrir Xcode
3. Archive → Distribute App
4. Upload vers App Store Connect

---

## 📖 Documentation Supplémentaire

### Fichiers de Documentation Disponibles

| Fichier | Description |
|---------|-------------|
| `API_SWAGGER_ANALYSIS.md` | Analyse complète API backend Swagger |
| `BACKEND_DONATIONS_SPEC.md` | Spécifications API dons (21KB) |
| `BACKEND_WALLET_API_SPECIFICATION.md` | Spécifications API portefeuille (22KB) |
| `GUIDE_CONFIGURATION_CINETPAY.md` | Configuration paiements CinetPay |
| `GUIDE_RECUPERATION_CLE_SIGNATURE.md` | Récupération keystore Android |
| `README_NOTIFICATIONS.md` | Guide notifications Firebase |
| `TESTING_GUIDE_NOTIFICATIONS.md` | Tests notifications |
| `BEFORE_AFTER_NOTIFICATION.md` | Implémentation notifications |
| `PLAN_LIVRAISON_48H.md` | Plan de livraison 48h |
| `livekit_api_requirements.md` | Exigences API LiveKit |

### Liens Utiles

- **API Backend**: https://monapi.eglisesetserviteursdedieu.com/api
- **Documentation Flutter**: https://docs.flutter.dev
- **LiveKit Docs**: https://docs.livekit.io
- **CinetPay Docs**: https://docs.cinetpay.com
- **Firebase Docs**: https://firebase.google.com/docs

---

## 🔐 Variables d'Environnement

### Fichier `.env`

```env
# CinetPay Configuration
CINETPAY_API_KEY=14638022065a1ece323e8456.99379118
CINETPAY_SITE_ID=617170
CINETPAY_NOTIFY_URL=https://monapi.eglisesetserviteursdedieu.com/api/donations/webhook
CINETPAY_RETURN_URL=aesd://donation/success

# Backend API
API_BASE_URL=https://monapi.eglisesetserviteursdedieu.com/api
```

**Accès dans le code**:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Charger au démarrage (main.dart)
await dotenv.load(fileName: ".env");

// Utiliser
String apiKey = dotenv.env['CINETPAY_API_KEY']!;
```

---

## 🐛 Debugging & Logging

### Activer les Logs

```dart
// Dans main.dart
debugPrint('Mon message de debug');

// Logs HTTP (Dio)
dio.interceptors.add(LogInterceptor(
  request: true,
  responseBody: true,
  error: true,
));
```

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

---

## 🧪 Tests

### Lancer les Tests

```bash
# Tous les tests
flutter test

# Tests spécifiques
flutter test test/widget_test.dart

# Avec coverage
flutter test --coverage
```

---

## 🚀 Performance

### Optimisations Implémentées

- **Image Caching**: `fast_cached_network_image`
- **Lazy Loading**: Pagination API
- **Shimmer Effects**: Placeholders élégants
- **Provider**: State management optimisé
- **Build Release**: Minification & obfuscation

---

## 🛡️ Sécurité

### Bonnes Pratiques Implémentées

- ✅ JWT stocké dans `flutter_secure_storage`
- ✅ Variables sensibles dans `.env` (non commité)
- ✅ Keystore Android protégé
- ✅ HTTPS uniquement
- ✅ Validation input côté client
- ✅ Gestion erreurs API

### ⚠️ À NE PAS COMMITER

```
.env
android/key.properties
android/app/upload-keystore.jks
ios/Runner/GoogleService-Info.plist (si contient secrets)
```

---

## 👥 Contribution & Passation

### Convention de Code

- **Dart Style Guide**: https://dart.dev/guides/language/effective-dart/style
- **Linter**: Configuré dans `analysis_options.yaml`
- **Format code**: `flutter format .`

### Structure de Commits

```
type(scope): description courte

[Description détaillée optionnelle]

[Breaking changes si applicable]
```

**Types**: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

**Examples**:
```
feat(wallet): add withdrawal confirmation dialog
fix(auth): resolve JWT expiration bug
docs(readme): update installation instructions
```

### Checklist pour Nouveau Développeur

- [ ] Installer Flutter SDK
- [ ] Cloner le repo
- [ ] Configurer `.env`
- [ ] Lire ce README
- [ ] Consulter `API_SWAGGER_ANALYSIS.md`
- [ ] Lancer `flutter pub get`
- [ ] Tester build: `flutter run`
- [ ] Explorer la structure `/lib`
- [ ] Comprendre les Providers
- [ ] Tester une feature (ex: login)

---

## 📞 Support & Contact

Pour toute question technique:

1. Lire ce README complètement
2. Consulter les docs dans `/`
3. Vérifier l'API backend Swagger
4. Consulter les logs Flutter

---

## 🗂️ Résumé Architecture en un Coup d'Œil

```
📱 AESD Buzz
├── 🎨 UI (Pages + Components)
├── 🔄 State (18 Providers)
├── 🌐 Services (9 Services)
├── 📊 Data (28 Models + 16 Requests)
├── 🔐 Auth (JWT + Secure Storage)
├── 💰 Payments (CinetPay)
├── 📹 Live (LiveKit)
├── 🔔 Notifications (FCM)
└── 🌍 i18n (ar, en, fr)
```

**Version du README**: 1.0.0  
**Dernière mise à jour**: 2026-02-13  
**Auteur**: Équipe AESD Buzz

---

**📌 Note Finale**: Ce README est un document vivant. Pensez à le mettre à jour lors de changements majeurs dans l'architecture ou les dépendances.
