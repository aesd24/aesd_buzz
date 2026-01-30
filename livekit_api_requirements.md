# Exigences de l'API LiveKit

Ce document détaille les endpoints de l'API backend requis par le frontend AESD Buzz pour supporter les fonctionnalités LiveKit. Ces endpoints correspondent à l'implémentation dans `lib/services/livekit_service.dart`.

## URL de Base
Tous les endpoints sont relatifs à l'URL de base de l'application :
**`https://monapi.eglisesetserviteursdedieu.com`**

Les chemins complets ressembleront à : `https://monapi.eglisesetserviteursdedieu.com/api/livekit/...`

---

## Gestion des Rooms (Salle de Live)

### 1. Créer une Room
Crée une nouvelle room LiveKit et retourne les détails de connexion (token).

*   **Endpoint** : `POST /api/livekit/create-room`
*   **Corps de la Requête (JSON)** :
    ```json
    {
      "roomName": "string (unique)",
      "participantName": "string",
      "participantId": "integer",
      "title": "string",
      "description": "string",
      "isPublic": "boolean"
    }
    ```
*   **Réponse Attendue** :
    ```json
    {
      "data": {
        "accessToken": "jwt_token_for_livekit_sdk",
        "liveKitServerUrl": "wss://votre-serveur-livekit.com",
        "roomName": "string",
        "title": "string",
        "description": "string",
        "hostName": "string",
        "hostId": "integer",
        "startedAt": "iso8601_string",
        "participantCount": "integer",
        "shareUrl": "string",
        "isPublic": "boolean",
        "churchName": "string (optionnel)",
        "thumbnail": "string (optionnel)"
      }
    }
    ```

### 2. Rejoindre une Room
Génère un token pour qu'un utilisateur rejoigne une room existante (ex: en tant que spectateur).

*   **Endpoint** : `POST /api/livekit/join-room`
*   **Corps de la Requête (JSON)** :
    ```json
    {
      "roomName": "string",
      "participantName": "string",
      "participantId": "integer",
      "role": "string (ex: 'viewer')"
    }
    ```
*   **Réponse Attendue** :
    ```json
    {
      "data": {
        "accessToken": "jwt_token_for_livekit_sdk",
        "liveKitServerUrl": "wss://votre-serveur-livekit.com",
        "roomName": "string",
        "title": "string",
        "description": "string",
        "hostName": "string",
        "hostId": "integer",
        "startedAt": "iso8601_string",
        "participantCount": "integer",
        "shareUrl": "string",
        "isPublic": "boolean",
        "churchName": "string (optionnel)",
        "thumbnail": "string (optionnel)"
      }
    }
    ```

### 3. Terminer une Room
Met fin à une session live.

*   **Endpoint** : `POST /api/livekit/end-room`
*   **Corps de la Requête (JSON)** :
    ```json
    {
      "roomName": "string",
      "participantId": "integer"
    }
    ```
*   **Réponse** : `200 OK`

### 4. Mettre en Pause une Room
Met en pause ou reprend une session (ex: arrête l'enregistrement ou masque du listing).

*   **Endpoint** : `POST /api/livekit/pause-room`
*   **Corps de la Requête (JSON)** :
    ```json
    {
      "roomName": "string",
      "isPaused": "boolean"
    }
    ```
*   **Réponse** : `200 OK`

---

## Récupération de Données

### 5. Liste des Lives Actifs
Liste toutes les rooms actuellement en direct.

*   **Endpoint** : `GET /api/livekit/rooms`
*   **Réponse Attendue** :
    ```json
    {
      "data": [
        {
          "roomName": "string",
          "title": "string",
          "description": "string",
          "hostName": "string",
          "hostId": "integer",
          "startedAt": "iso8601_string",
          "participantCount": "integer",
          "isLive": "boolean",
          "shareUrl": "string",
          "church": {
            "name": "string (optionnel)",
            "location": "string (optionnel)"
          }
        }
      ]
    }
    ```

### 6. Infos d'une Room
Obtient les détails d'une room spécifique.

*   **Endpoint** : `GET /api/livekit/room-info/{roomName}`
*   **Réponse Attendue** :
    ```json
    {
      "data": {
        "roomName": "string",
        "title": "string",
        "description": "string",
        "hostName": "string",
        "hostId": "integer",
        "startedAt": "iso8601_string",
        "participantCount": "integer",
        "isLive": "boolean",
        "shareUrl": "string",
        "church": {
            "name": "string (optionnel)",
            "location": "string (optionnel)"
          }
      }
    }
    ```

---

## Interactions & Statistiques

### 7. Sauvegarder Stats Spectateur
Enregistre les statistiques de la session d'un spectateur.

*   **Endpoint** : `POST /api/livekit/save-viewer-stats`
*   **Corps de la Requête (JSON)** :
    ```json
    {
      "roomName": "string",
      "participantId": "integer",
      "watchDuration": "integer (secondes)",
      "quality": "string",
      "startedAt": "iso8601_string",
      "endedAt": "iso8601_string"
    }
    ```
*   **Réponse** : `200 OK`

### 8. Mute Participant (Modération)
Permet à un modérateur/hôte de couper le micro/caméra d'un participant.

*   **Endpoint** : `POST /api/livekit/mute-participant`
*   **Corps de la Requête (JSON)** :
    ```json
    {
      "roomName": "string",
      "participantId": "integer",
      "audioMuted": "boolean",
      "videoMuted": "boolean"
    }
    ```
*   **Réponse** : `200 OK`

### 9. Expulser Participant (Modération)
Permet à un modérateur/hôte d'éjecter un participant.

*   **Endpoint** : `POST /api/livekit/remove-participant`
*   **Corps de la Requête (JSON)** :
    ```json
    {
      "roomName": "string",
      "participantToRemoveId": "integer",
      "reason": "string (optionnel)"
    }
    ```
*   **Réponse** : `200 OK`

---

## Chat & Enregistrements

### 10. Récupérer Messages du Chat
Récupère l'historique de chat d'une room.

*   **Endpoint** : `GET /api/livekit/messages/{roomName}`
*   **Paramètres Query** :
    *   `limit` : entier (défaut 50)
    *   `offset` : entier (défaut 0)
*   **Réponse Attendue** :
    {
      "data": [
        {
          "participantName": "string",
          "message": "string",
          "timestamp": "iso8601_string",
          "roomName": "string",
          "participantId": "integer"
        }
      ]
    }
    ```

### 11. Envoyer Message Chat
Envoie un message dans le chat de la room.

*   **Endpoint** : `POST /api/livekit/send-message`
*   **Corps de la Requête (JSON)** :
    ```json
    {
      "roomName": "string",
      "participantId": "integer",
      "participantName": "string",
      "message": "string",
      "timestamp": "iso8601_string"
    }
    ```
*   **Réponse** : `200 OK` ou `201 Created`

### 12. Liste des Enregistrements
Liste les enregistrements disponibles des streams passés.

*   **Endpoint** : `GET /api/livekit/recordings`
*   **Réponse Attendue** :
    ```json
    {
      "data": [
        {
          "roomName": "string",
          "recordingUrl": "string",
          "duration": "integer",
          "size": "integer (bytes)",
          "createdAt": "iso8601_string",
          "thumbnailUrl": "string (optionnel)"
        }
      ]
    }
    ```
