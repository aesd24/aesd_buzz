# 🎥 LiveKit - Structure Complète du Projet

## 📁 Architecture Fichiers

```
lib/
├── pages/live/
│   ├── main.dart ............................ Page listant les lives actifs (Accueil Live)
│   ├── start_live.dart ..................... Formulaire création nouveau live
│   ├── live_room.dart ...................... Interface salle de live (streaming)
│   └── live_page_simple.dart ............... Version simple (optionnel)
│
├── provider/
│   └── live_provider.dart ................. State management (ChangeNotifier)
│
├── models/
│   └── live_model.dart .................... Data classes
│       ├── LiveRoom
│       ├── LiveRoomInfo
│       ├── CreateLiveRoomRequest
│       ├── JoinLiveRoomRequest
│       └── ChatMessage
│
└── services/
    └── livekit_service.dart .............. Couche API vers backend

```

---

## 🎯 Pages LiveKit

### 1️⃣ **LivePage (main.dart)** - 478 lignes
**Fonction**: Afficher tous les lives actifs
**Couleur**: Vert (#3ae700)

**Contenu:**
- 🔴 TabBar avec 2 onglets:
  - "Lives Actifs" - Liste des diffusions en cours
  - "Enregistrements" - Videos archivées
- 🎥 Cards pour chaque live:
  - Nom du host
  - Titre du live
  - Nombre de participants 👥
  - Badge rouge "LIVE" pulsant
  - Eglise du host
- ➕ FAB vert pour créer un nouveau live
- 🔄 Pull-to-refresh

**State:**
- Animations fade-in (800ms)
- TabController pour navigation
- Récupère lives via `context.read<LiveProvider>().fetchActiveLives()`

---

### 2️⃣ **StartLivePage (start_live.dart)** - 482 lignes
**Fonction**: Créer une nouvelle diffusion
**Couleur**: Vert avec icône gradient

**Contenu:**
```
┌─────────────────────────────────────┐
│  💚 Démarrer une diffusion         │
├─────────────────────────────────────┤
│  Titre: [_____________________]      │
│  Description: [_____________________] │
│  Visibilité: [Public] [Privé]       │
├─────────────────────────────────────┤
│  Fonctionnalités:                   │
│  📤 Partager avec tous              │
│  👥 Créer une communauté            │
│  📹 Enregistrement auto             │
├─────────────────────────────────────┤
│  [Démarrer la diffusion]            │
└─────────────────────────────────────┘
```

**Logique:**
1. Valide le titre
2. Appelle `liveProvider.createLiveRoom()`
3. Si OK → Navigue vers `LiveRoomPage` (host=true)
4. Si erreur → Affiche message d'erreur

---

### 3️⃣ **LiveRoomPage (live_room.dart)** - 763 lignes
**Fonction**: Interface de streaming en temps réel
**Couleur**: Vert avec contrôles

**Layout:**
```
┌─────────────────────────────────────┐
│ AppBar: "Titre du Live" | Participants: 42 │
├─────────────────────────────────────┤
│                                     │
│      📹 VIDEO STREAM AREA          │
│        (Placeholder StreamView)    │
│                                     │
├─────────────────────────────────────┤
│ [Micro] [Camera] [...More Options] │ ← Host Controls
├─────────────────────────────────────┤
│ [❤️ Like] [📤 Share] [💬 Chat]     │ ← Viewer Actions
└─────────────────────────────────────┘
```

**Host Controls (si isHost=true):**
- 🎤 Microphone toggle
- 📹 Camera toggle
- ⛔ Stop live
- 📋 More options

**Viewer Features (si isHost=false):**
- ❤️ Like button
- 📤 Share live link
- 💬 Chat panel

**Chat:**
- TextEditingController pour message
- List de messages affichée
- Envoi via `sendMessage()`

---

## 🎛️ LiveProvider - State Management

**Classe**: `LiveProvider extends ChangeNotifier`

### État Interne:
```dart
List<LiveRoomInfo> _activeLives;      // Tous les lives actifs
LiveRoom? _currentRoom;               // Room courante
bool _isLoading;                      // Chargement en cours
String? _error;                       // Message d'erreur
int _participantCount;                // Nombre de participants
```

### Méthodes Principales:

| Méthode | Retour | Fonction |
|---------|--------|----------|
| `createLiveRoom()` | `LiveRoom?` | Créer nouvelle room |
| `joinLiveRoom()` | `LiveRoom?` | Rejoindre room existante |
| `fetchActiveLives()` | `void` | Charger tous les lives actifs |
| `leaveLiveRoom()` | `Future<void>` | Quitter room |
| `sendMessage()` | `Future<void>` | Envoyer message chat |
| `sendLike()` | `Future<void>` | Envoyer un like |
| `muteParticipant()` | `Future<void>` | Mute participant (host only) |
| `removeParticipant()` | `Future<void>` | Kick participant (host only) |

---

## 📦 Data Models (live_model.dart)

### **LiveRoom**
```dart
class LiveRoom {
  final String roomName;            // unique-id
  final String roomId;              // LiveKit ID
  final String title;               // Titre du live
  final String? description;        // Description
  final String hostName;            // Nom du host
  final String hostChurchName;      // Eglise du host
  final String token;               // JWT pour connexion
  final String serverUrl;           // ws://livekit-server
  final DateTime createdAt;         // Quand créé
  final bool isPublic;              // Visible publiquement?
}
```

### **LiveRoomInfo** (pour liste)
```dart
class LiveRoomInfo {
  final String roomName;
  final String title;
  final int participantCount;
  final String hostName;
  final String hostChurchName;
  final DateTime createdAt;
  final String? thumbnailUrl;
  final bool isRecording;           // En enregistrement?
  final String shareUrl;            // Lien partage
}
```

### **ChatMessage**
```dart
class ChatMessage {
  final String id;
  final String participantId;
  final String participantName;
  final String message;
  final DateTime timestamp;
}
```

---

## 🔗 LiveKitService - Couche API

**Fichier**: `lib/services/livekit_service.dart`

### API Endpoints:

| Endpoint | Méthode | Fonction |
|----------|---------|----------|
| `/api/livekit/create-room` | POST | Créer room |
| `/api/livekit/join-room` | POST | Rejoindre room |
| `/api/livekit/end-room` | POST | Terminer live |
| `/api/livekit/rooms` | GET | Lister actifs |
| `/api/livekit/room-info/{name}` | GET | Info room spécifique |
| `/api/livekit/save-viewer-stats` | POST | Tracker analytics |
| `/api/livekit/mute-participant` | POST | Mute (host) |
| `/api/livekit/remove-participant` | POST | Remove (host) |

---

## 🎨 UI/UX Design

### Couleurs:
- **Primary**: `#3ae700` (Vert vif)
- **Secondary**: `#ffffff` (Blanc)
- **Accent**: `#ff0000` (Rouge pour LIVE badge)
- **Background**: `#f5f5f5` (Gris clair)

### Animations:
- Fade-in: 500-800ms
- LIVE badge: Pulsing rouge
- Transitions: Smooth avec CurvedAnimation

### Components:
- Cards avec ombre
- Gradient buttons
- Chat bubble style
- Participant avatars

---

## 🔄 Flux Utilisateur

### Pour Créer un Live:
```
1. Accueil → FAB "Créer Live"
   ↓
2. StartLivePage (Formulaire)
   ├─ Titre (required)
   ├─ Description (optional)
   └─ Public/Privé toggle
   ↓
3. Click "Démarrer"
   ↓
4. LiveProvider.createLiveRoom()
   ├─ Génère roomName unique
   ├─ Appelle backend: POST /api/livekit/create-room
   └─ Retourne LiveRoom avec token
   ↓
5. Navigate → LiveRoomPage(isHost=true)
   ↓
6. Streaming actif! 🎬
```

### Pour Rejoindre un Live:
```
1. LivePage (Accueil)
   ├─ Affiche lista lives actifs
   ├─ 🔴 LIVE badges pulsants
   └─ Participant count
   ↓
2. Click sur une card
   ↓
3. LiveProvider.joinLiveRoom()
   ├─ Appelle backend: POST /api/livekit/join-room
   └─ Retourne LiveRoom avec token viewer
   ↓
4. Navigate → LiveRoomPage(isHost=false)
   ↓
5. Viewing actif! 👀
   ├─ Chat available
   ├─ Like button
   └─ Share option
```

---

## ⚡ Prérequis Backend

**Doit être implémenté:**

1. ✅ LiveKit Server (external service)
   - URL: `ws://livekit-server:7880`
   - API Key + Secret

2. ✅ Endpoints Laravel:
   - POST /api/livekit/create-room
   - POST /api/livekit/join-room
   - GET /api/livekit/rooms
   - POST /api/livekit/end-room
   - Etc. (voir LIVEKIT_BACKEND_REQUIREMENTS.md)

3. ✅ Database:
   - Table `live_rooms`
   - Table `live_participants`
   - Table `live_chats`
   - Table `live_recordings`

---

## 🚀 Pour Compiler

```bash
# Nettoyer
flutter clean
flutter pub get

# Build Debug
flutter run

# Build Release
flutter build apk
flutter build ios
```

**Vert LiveKit devrait apparaître:**
- ✅ HomePage bottom nav → "Live" tab
- ✅ Accueil Live avec lives actifs
- ✅ FAB vert "Créer Live"
- ✅ Clic FAB → StartLivePage

---

## 📊 État Actuel

| Composant | Status | Notes |
|-----------|--------|-------|
| UI Pages | ✅ 100% | 3 pages complètes |
| Animations | ✅ 100% | Fade-in, pulsing |
| Provider | ✅ 100% | ChangeNotifier fonctionnel |
| Models | ✅ 100% | Data classes prêtes |
| Service | ✅ 100% | API calls ready |
| **Backend Integration** | ⏳ 0% | À implémenter sur Laravel |
| **Real Streaming** | ⏳ 0% | Nécessite LiveKit SDK |

---

## 🎯 Prochaines Étapes

1. **Backend** - Implémenter les endpoints
2. **LiveKit SDK** - Intégrer la vraie capture vidéo
3. **WebRTC** - Connecter aux streams réels
4. **Recording** - Archivage des lives
5. **Analytics** - Tracking des viewers

