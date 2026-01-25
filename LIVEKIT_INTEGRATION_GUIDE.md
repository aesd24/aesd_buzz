# 🎥 LiveKit Integration Guide - AESD Buzz

## Overview
Ce guide explique comment intégrer complètement LiveKit dans l'application AESD Buzz avec les pages créées et les données du backend.

---

## 1️⃣ **Installation des Dépendances**

Add to `pubspec.yaml`:
```yaml
dependencies:
  livekit:
    git:
      url: https://github.com/livekit/client-sdk-flutter.git
  share_plus: ^7.0.0
  dio: ^5.3.0
  provider: ^6.0.0
```

Run:
```bash
flutter pub get
```

---

## 2️⃣ **File Structure**

```
lib/
├── models/
│   └── live_model.dart                    # Models pour LiveKit
├── services/
│   └── livekit_service.dart              # Service API pour LiveKit
├── provider/
│   └── live_provider.dart                 # State management
└── pages/
    └── live/
        ├── main.dart                      # Page principale (liste des lives)
        ├── start_live.dart                # Page de création de live
        └── live_room.dart                 # Page du streaming
```

---

## 3️⃣ **Setup des Providers**

In `main.dart` or your provider setup:

```dart
ChangeNotifierProvider(
  create: (_) => LiveProvider(
    liveKitService: LiveKitService(
      dio: Dio(),
      baseUrl: 'https://your-api.com', // Backend API URL
    ),
  ),
),
```

---

## 4️⃣ **Navigation Integration**

### Add to your main navigation/dashboard:

```dart
// Dans votre TabBar ou Navigation
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LivePage()),
    );
  },
  child: const Text('Lives'),
),
```

### Or in a menu:

```dart
ListTile(
  leading: const Icon(FontAwesomeIcons.broadcast),
  title: const Text('Diffusions en Direct'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LivePage()),
  ),
),
```

---

## 5️⃣ **Backend Integration Points**

### The app expects these endpoints from your backend:

#### 1. **Create Room**
```
POST /api/livekit/create-room

Request: CreateLiveRoomRequest
Response: { data: LiveRoom }
```

#### 2. **Join Room**
```
POST /api/livekit/join-room

Request: JoinLiveRoomRequest
Response: { data: LiveRoom }
```

#### 3. **Get Active Lives**
```
GET /api/livekit/rooms

Response: { data: [LiveRoomInfo] }
```

#### 4. **Get Room Info**
```
GET /api/livekit/room-info/{roomName}

Response: { data: LiveRoomInfo }
```

#### 5. **End Room**
```
POST /api/livekit/end-room

Request: { roomName, participantId }
Response: { data: { roomName, endedAt, recordingUrl, viewerCount, duration } }
```

---

## 6️⃣ **Key Variables Backend Must Provide**

### In Create Room Response:
```json
{
  "accessToken": "JWT token for WebRTC connection",
  "roomName": "unique-room-identifier",
  "liveKitServerUrl": "ws://livekit-server.com:7880",
  "shareUrl": "https://app.example.com/live/{roomName}"
}
```

### In Get Active Lives Response:
```json
[
  {
    "roomName": "string",
    "title": "string",
    "description": "string",
    "hostName": "string",
    "hostId": "integer",
    "participantCount": "integer",
    "startedAt": "ISO 8601",
    "church": { "name": "string" }
  }
]
```

---

## 7️⃣ **Environment Configuration**

Create `lib/config/live_config.dart`:

```dart
class LiveConfig {
  // Get from your backend or config
  static const String liveKitServerUrl = 'ws://your-livekit-server.com:7880';
  static const String apiBaseUrl = 'https://your-api.com';
  
  // LiveKit server credentials (backend only, never expose)
  static const String apiKey = 'YOUR_LIVEKIT_API_KEY';
  static const String apiSecret = 'YOUR_LIVEKIT_API_SECRET';
}
```

---

## 8️⃣ **Using the Live Module**

### Start a Live:
```dart
final liveProvider = context.read<LiveProvider>();

final room = await liveProvider.createLiveRoom(
  title: 'Service du dimanche',
  description: 'Service principal',
  participantName: user.name,
  participantId: user.id,
  isPublic: true,
);
```

### Join a Live:
```dart
final room = await liveProvider.joinLiveRoom(
  roomName: 'church-service-123',
  participantName: user.name,
  participantId: user.id,
);
```

### Fetch Active Lives:
```dart
await liveProvider.fetchActiveLives();
List<LiveRoomInfo> lives = liveProvider.activeLives;
```

---

## 9️⃣ **Color Theme - Green & White**

The live pages use:
- **Primary Green**: `#3ae700`
- **Dark Green**: `#2a9000`
- **Accent**: Red for live indicator (`#ff4444`)
- **Background**: White/Light Gray

All components follow the AESD Buzz green/white theme for consistency.

---

## 🔟 **Share Link Feature**

When users want to share the live:

```dart
Share.share(
  'Rejois-moi en live: https://app.example.com/live/{roomName}',
  subject: 'Diffusion en direct',
);
```

**Backend Requirement**: 
- Generate a `shareUrl` when creating a room
- Handle deep linking to accept `roomName` parameter

---

## 1️⃣1️⃣ **Real WebRTC Implementation** (Next Phase)

Once backend provides tokens, implement actual video streaming:

```dart
import 'package:livekit/livekit.dart';

class LiveStreamManager {
  late Room room;
  late LocalParticipant localParticipant;

  Future<void> connect(String url, String token) async {
    room = Room();
    room.engine.createAudioTrack();
    room.engine.createVideoTrack();
    
    await room.connect(url, token);
    localParticipant = room.localParticipant!;
  }

  Future<void> disconnect() async {
    await room.disconnect();
  }
}
```

---

## 1️⃣2️⃣ **Error Handling**

The app handles:
- ✅ Network errors
- ✅ Invalid tokens
- ✅ Room not found
- ✅ Room full
- ✅ Server unavailable

Check `LiveProvider.error` for error messages.

---

## 1️⃣3️⃣ **Testing Checklist**

- [ ] Backend running and accessible
- [ ] All 5 main endpoints implemented
- [ ] JWT tokens generated correctly
- [ ] LiveKit server reachable
- [ ] Create room works and returns token
- [ ] Join room works for viewers
- [ ] Share URL generates correctly
- [ ] Chat system functional
- [ ] Recording saves properly
- [ ] App compiles without errors

---

## 1️⃣4️⃣ **Pages Added to App**

### `LivePage` (main.dart)
- Lists all active livestreams
- Shows live indicators
- FAB to start new live
- Tabs: Active Lives | Recordings

### `StartLivePage` (start_live.dart)
- Form to create new live
- Title & description input
- Public/Private toggle
- Feature highlights

### `LiveRoomPage` (live_room.dart)
- Video streaming area (placeholder for actual stream)
- Host controls: Microphone, Camera on/off
- Viewer actions: Share, Like, Chat
- Chat panel in real-time
- Stop live button for host
- Participant counter

---

## 1️⃣5️⃣ **Deployment Considerations**

1. **WebRTC Ports**: Ensure firewall allows LiveKit ports
2. **CORS**: Backend must allow app domain
3. **SSL/TLS**: Use `wss://` for production
4. **Rate Limiting**: Backend should limit room creation
5. **Recording Storage**: Allocate space for video storage
6. **Bandwidth**: Plan for concurrent streams

---

## 1️⃣6️⃣ **API Response Format**

All endpoints must follow this format:

```json
{
  "success": true,
  "data": { /* payload */ },
  "error": null
}
```

Error response:
```json
{
  "success": false,
  "data": null,
  "error": "Detailed error message"
}
```

---

## 1️⃣7️⃣ **User Flow**

### Host (Serviteur de Dieu):
1. Tap "Démarrer un Live"
2. Enter title & description
3. Select public/private
4. Start streaming
5. Share link with congregation
6. Control mic/camera
7. End when done

### Viewer (Congrégation):
1. See live in "Diffusions en Direct"
2. Tap to join
3. Watch stream
4. Participate in chat
5. Like the content
6. Share with others

---

## 📝 **Next Steps**

1. ✅ Frontend pages created
2. ⏳ Backend implement endpoints
3. ⏳ LiveKit server setup
4. ⏳ Implement WebRTC streaming
5. ⏳ Add recording functionality
6. ⏳ Deploy to production

---

**Status**: Frontend Ready for Backend Integration  
**Last Updated**: 19 Janvier 2026

For questions or issues, refer to:
- LiveKit Docs: https://docs.livekit.io
- Flutter SDK: https://github.com/livekit/client-sdk-flutter
