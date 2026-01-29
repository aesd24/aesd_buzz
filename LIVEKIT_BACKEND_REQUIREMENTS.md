# 🎥 LiveKit Integration - Backend Requirements

## Overview
Ce document détaille tous les endpoints et données que le **backend doit fournir** pour intégrer complètement LiveKit dans l'application Flutter AESD Buzz.

---

## ⚠️ Champs requis pour que LiveKit fonctionne (SDK)

Le SDK LiveKit Flutter appelle `Room.connect(url, token)`. Le backend **doit** donc retourner au minimum :

| Champ | Type | Endpoint | Description |
|-------|------|----------|-------------|
| **accessToken** | string | create-room, join-room | JWT LiveKit (généré avec votre API Key/Secret). Obligatoire. |
| **liveKitServerUrl** | string | create-room, join-room | URL WebSocket du serveur LiveKit (ex: `wss://live.example.com`). Obligatoire. |
| **roomName** | string | create-room, join-room | Identifiant de la room (cohérent avec le token). Obligatoire. |

Sans `accessToken` et `liveKitServerUrl`, la connexion à la room échouera côté app. Tous les autres champs sont utilisés pour l’affichage (titre, partage, etc.).

---

## 1️⃣ **Authentication & Room Token Generation**

### Endpoint: `POST /api/livekit/create-room`
**Purpose**: Créer une room livestream et générer les tokens d'accès

**Request Body**:
```json
{
  "roomName": "string (unique, format: church-service-{timestamp})",
  "participantName": "string (nom du serviteur de Dieu)",
  "participantId": "integer (user ID)",
  "title": "string (titre du live)",
  "description": "string (description optionnelle)",
  "isPublic": "boolean (si accessible au public)"
}
```

**Response** (tous les champs ci‑dessous pour que le frontend et LiveKit fonctionnent) :
```json
{
  "success": true,
  "data": {
    "roomName": "church-service-1705681200",
    "accessToken": "string (JWT LiveKit pour le HOST - OBLIGATOIRE)",
    "liveKitServerUrl": "wss://votre-serveur-livekit.com (OBLIGATOIRE)",
    "shareUrl": "string (lien unique pour rejoindre le live)",
    "title": "string",
    "description": "string",
    "hostName": "string",
    "hostId": "integer",
    "startedAt": "ISO 8601 timestamp",
    "participantCount": 0,
    "isPublic": true,
    "churchName": "string (optionnel)",
    "thumbnail": "string URL (optionnel)",
    "roomId": "string (identifiant LiveKit, optionnel)",
    "createdAt": "ISO 8601 timestamp",
    "expiresAt": "ISO 8601 timestamp (optionnel)"
  },
  "error": null
}
```

**Error Cases**:
```json
{
  "success": false,
  "data": null,
  "error": "string (ex: 'Room creation failed', 'Invalid user')"
}
```

---

## 2️⃣ **Join Existing Room (For Viewers)**

### Endpoint: `POST /api/livekit/join-room`
**Purpose**: Générer un token pour rejoindre une room existante (spectateurs)

**Request Body**:
```json
{
  "roomName": "string",
  "participantName": "string (nom du spectateur)",
  "participantId": "integer (user ID)",
  "role": "viewer"
}
```

**Response** (format plat recommandé ; le frontend accepte aussi `roomInfo` imbriqué) :
```json
{
  "success": true,
  "data": {
    "roomName": "church-service-1705681200",
    "accessToken": "string (JWT LiveKit pour le spectateur - OBLIGATOIRE)",
    "liveKitServerUrl": "wss://votre-serveur-livekit.com (OBLIGATOIRE)",
    "shareUrl": "string",
    "title": "string",
    "description": "string",
    "hostName": "string",
    "hostId": "integer",
    "startedAt": "ISO 8601 timestamp",
    "participantCount": "integer",
    "isPublic": true,
    "churchName": "string (optionnel)",
    "thumbnail": "string URL (optionnel)"
  },
  "error": null
}
```

**Alternative avec `roomInfo` imbriqué** (le frontend fusionne avec la racine) :
```json
{
  "success": true,
  "data": {
    "roomName": "church-service-1705681200",
    "accessToken": "string (OBLIGATOIRE)",
    "liveKitServerUrl": "wss://... (OBLIGATOIRE)",
    "roomInfo": {
      "title": "string",
      "description": "string",
      "hostName": "string",
      "hostId": "integer",
      "participantCount": "integer",
      "isLive": "boolean",
      "shareUrl": "string"
    }
  },
  "error": null
}
```

---

## 3️⃣ **Room Management**

### Endpoint: `POST /api/livekit/end-room`
**Purpose**: Terminer le livestream

**Request Body**:
```json
{
  "roomName": "string",
  "participantId": "integer (verification que c'est le host)"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "roomName": "string",
    "endedAt": "ISO 8601 timestamp",
    "recordingUrl": "string (optionnel - si enregistrement activé)",
    "viewerCount": "integer (nombre de spectateurs qui ont regardé)",
    "duration": "integer (durée en secondes)"
  },
  "error": null
}
```

### Endpoint: `POST /api/livekit/pause-room`
**Purpose**: Mettre en pause le livestream (garder la room active)

**Request Body**:
```json
{
  "roomName": "string",
  "isPaused": "boolean"
}
```

### Endpoint: `GET /api/livekit/rooms`
**Purpose**: Lister tous les lives actifs (pour la page d'accueil)

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "roomName": "church-service-1705681200",
      "title": "Service du dimanche",
      "hostName": "Pasteur Jean",
      "startedAt": "ISO 8601 timestamp",
      "participantCount": "integer",
      "shareUrl": "string",
      "thumbnail": "string (URL image optional)",
      "church": {
        "id": "integer",
        "name": "string"
      }
    }
  ],
  "error": null
}
```

---

## 4️⃣ **Viewer Statistics & Info**

### Endpoint: `GET /api/livekit/room-info/{roomName}`
**Purpose**: Obtenir les infos d'une room spécifique

**Response**:
```json
{
  "success": true,
  "data": {
    "roomName": "string",
    "title": "string",
    "description": "string",
    "hostName": "string",
    "hostId": "integer",
    "startedAt": "ISO 8601 timestamp",
    "participantCount": "integer",
    "isLive": "boolean",
    "shareUrl": "string",
    "church": {
      "id": "integer",
      "name": "string",
      "location": "string"
    }
  },
  "error": null
}
```

### Endpoint: `POST /api/livekit/save-viewer-stats`
**Purpose**: Enregistrer les stats du spectateur (analytics)

**Request Body**:
```json
{
  "roomName": "string",
  "participantId": "integer",
  "watchDuration": "integer (en secondes)",
  "quality": "string (HD, SD, LQ)",
  "startedAt": "ISO 8601 timestamp",
  "endedAt": "ISO 8601 timestamp"
}
```

---

## 5️⃣ **Recording & Archive**

### Endpoint: `GET /api/livekit/recordings`
**Purpose**: Lister les enregistrements disponibles

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "recordingId": "string",
      "roomName": "string",
      "title": "string",
      "recordedAt": "ISO 8601 timestamp",
      "duration": "integer (secondes)",
      "videoUrl": "string (streaming URL)",
      "viewCount": "integer",
      "thumbnail": "string (URL)"
    }
  ],
  "error": null
}
```

---

## 6️⃣ **Configuration Variables Required**

### Backend Must Provide:
```env
# LiveKit Server
LIVEKIT_SERVER_URL=ws://your-livekit-server.com:7880
LIVEKIT_API_KEY=your-api-key
LIVEKIT_API_SECRET=your-api-secret

# JWT Token Configuration
JWT_SECRET=your-jwt-secret
TOKEN_EXPIRATION=3600 # 1 hour in seconds

# Room Configuration
DEFAULT_ROOM_TIMEOUT=86400 # 24 hours
MAX_PARTICIPANTS_PER_ROOM=500
RECORDING_ENABLED=true
RECORDING_STORAGE_PATH=/recordings
```

### Frontend Will Receive:
```json
{
  "liveKitServerUrl": "ws://your-livekit-server.com:7880",
  "apiBaseUrl": "https://your-api.com",
  "recordingEnabled": true
}
```

---

## 7️⃣ **Share Link Format**

### Share URL Structure:
```
https://app.example.com/live/{roomName}?token={shortCode}
```

**Backend Implementation**:
1. Générer un `shortCode` unique pour chaque room
2. Stocker mapping: `shortCode → roomName`
3. Retourner le lien partageable dans la réponse de création
4. Quand quelqu'un ouvre le lien, parser `roomName` et générer un token viewer

### QR Code:
```
Backend should generate QR code PNG pointing to the share URL
Response: { "qrCodeUrl": "data:image/png;base64,..." }
```

---

## 8️⃣ **Moderation & Controls**

### Endpoint: `POST /api/livekit/mute-participant`
**Purpose**: Mute/Unmute un participant

**Request Body**:
```json
{
  "roomName": "string",
  "participantId": "integer",
  "audioMuted": "boolean",
  "videoMuted": "boolean"
}
```

### Endpoint: `POST /api/livekit/remove-participant`
**Purpose**: Expulser un participant de la room

**Request Body**:
```json
{
  "roomName": "string",
  "participantToRemoveId": "integer",
  "reason": "string (optional)"
}
```

---

## 9️⃣ **Chat Integration (Optional)**

### Endpoint: `POST /api/livekit/send-message`
**Purpose**: Envoyer un message dans le chat en direct

**Request Body**:
```json
{
  "roomName": "string",
  "participantId": "integer",
  "participantName": "string",
  "message": "string",
  "timestamp": "ISO 8601 timestamp"
}
```

### Endpoint: `GET /api/livekit/messages/{roomName}`
**Purpose**: Récupérer l'historique de chat

**Query Parameters**:
```
?limit=50
?offset=0
```

---

## 🔟 **Error Codes Reference**

```json
{
  "ROOM_NOT_FOUND": 404,
  "ROOM_FULL": 409,
  "INVALID_TOKEN": 401,
  "UNAUTHORIZED": 403,
  "SERVER_ERROR": 500,
  "LIVEKIT_SERVICE_UNAVAILABLE": 503,
  "USER_NOT_FOUND": 404,
  "INVALID_ROOM_NAME": 400,
  "TOKEN_EXPIRED": 401
}
```

---

## Security Requirements ⚠️

### Backend Must:
✅ **Validate** participant ID against user session  
✅ **Verify** user has permission to create/join rooms  
✅ **Generate** secure JWT tokens with proper expiration  
✅ **Rate limit** room creation (prevent spam)  
✅ **Sanitize** room names and participant names  
✅ **Use HTTPS/WSS** for all communications  
✅ **Implement** proper CORS headers  
✅ **Log** all room activities for moderation  

---

## Database Schema Suggestions

### `live_rooms` table:
```sql
CREATE TABLE live_rooms (
  id INT PRIMARY KEY AUTO_INCREMENT,
  room_name VARCHAR(255) UNIQUE NOT NULL,
  host_id INT NOT NULL,
  title VARCHAR(255),
  description TEXT,
  started_at TIMESTAMP,
  ended_at TIMESTAMP NULL,
  is_public BOOLEAN DEFAULT true,
  church_id INT,
  recording_url VARCHAR(500),
  view_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (host_id) REFERENCES users(id),
  FOREIGN KEY (church_id) REFERENCES churches(id)
);
```

### `live_viewers` table:
```sql
CREATE TABLE live_viewers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  room_id INT NOT NULL,
  viewer_id INT NOT NULL,
  joined_at TIMESTAMP,
  left_at TIMESTAMP NULL,
  watch_duration INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (room_id) REFERENCES live_rooms(id),
  FOREIGN KEY (viewer_id) REFERENCES users(id)
);
```

---

## Testing Checklist

- [ ] Create room - retourne token valide
- [ ] Join room - spectateurs peuvent rejoindre
- [ ] End room - ferme correctement la room
- [ ] Share URL - ouvre la room sans erreur
- [ ] Token expiration - refuse accès après expiration
- [ ] Room timeout - auto-delete rooms inactives après 24h
- [ ] Participant limit - refuse nouveau participant si full
- [ ] Recording - enregistre et stocke vidéo
- [ ] Analytics - track viewer stats correctement

---

## Implementation Timeline Suggestion

1. **Phase 1** (Week 1): Endpoints de base (create, join, end)
2. **Phase 2** (Week 2): Room management & stats
3. **Phase 3** (Week 3): Recording & archive
4. **Phase 4** (Week 4): Moderation & advanced features

---

---

## Récap : champs attendus par le frontend

| Modèle | Source | Champs obligatoires pour LiveKit | Autres champs (affichage) |
|--------|--------|----------------------------------|----------------------------|
| **LiveRoom** | create-room, join-room | `accessToken`, `liveKitServerUrl`, `roomName` | title, description, hostName, hostId, startedAt, participantCount, shareUrl, isPublic, churchName, thumbnail |
| **LiveRoomInfo** | GET /rooms, GET /room-info/{roomName} | — | roomName, title, description, hostName, hostId, startedAt, participantCount, isLive, shareUrl, church.name, church.location |

Convention : **camelCase** pour tous les champs JSON (roomName, accessToken, liveKitServerUrl, participantCount, etc.).

---

**Status**: Ready for Backend Implementation  
**Last Updated**: Janvier 2026
