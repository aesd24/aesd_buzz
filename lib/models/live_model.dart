/// Model pour les données LiveKit.
/// Pour que [Room.connect] fonctionne, le backend doit retourner au minimum :
/// - [accessToken] : JWT LiveKit
/// - [liveKitServerUrl] : URL WebSocket (wss:// ou ws://)
/// - [roomName] : identifiant de la room
class LiveRoom {
  final String roomName;
  final String title;
  final String description;
  final String hostName;
  final int hostId;
  final String startedAt;
  final int participantCount;
  final String shareUrl;
  /// JWT requis par LiveKit SDK pour Room.connect(url, token).
  final String accessToken;
  /// URL du serveur LiveKit (wss://...) requise par Room.connect(url, token).
  final String liveKitServerUrl;
  final bool isPublic;
  final String? churchName;
  final String? thumbnail;

  /// Indique si les champs requis pour se connecter au SDK LiveKit sont présents.
  bool get canConnect => accessToken.isNotEmpty && liveKitServerUrl.isNotEmpty;

  LiveRoom({
    required this.roomName,
    required this.title,
    required this.description,
    required this.hostName,
    required this.hostId,
    required this.startedAt,
    required this.participantCount,
    required this.shareUrl,
    required this.accessToken,
    required this.liveKitServerUrl,
    required this.isPublic,
    this.churchName,
    this.thumbnail,
  });

  /// Parse depuis create-room ou join-room.
  /// Requis pour LiveKit SDK : accessToken, liveKitServerUrl, roomName.
  /// join-room peut retourner roomInfo (nested) : on fusionne avec la racine.
  factory LiveRoom.fromJson(Map<String, dynamic> json) {
    final roomInfo = json['roomInfo'] as Map<String, dynamic>?;
    String getStr(String key) =>
        json[key] ?? roomInfo?[key] ?? '';
    int getInt(String key) =>
        (json[key] ?? roomInfo?[key] ?? 0) is int
            ? (json[key] ?? roomInfo?[key] ?? 0) as int
            : int.tryParse((json[key] ?? roomInfo?[key])?.toString() ?? '0') ?? 0;
    bool getBool(String key) => json[key] ?? roomInfo?[key] ?? true;

    return LiveRoom(
      roomName: getStr('roomName'),
      title: getStr('title'),
      description: getStr('description'),
      hostName: getStr('hostName'),
      hostId: getInt('hostId'),
      startedAt: getStr('startedAt').isEmpty
          ? DateTime.now().toIso8601String()
          : getStr('startedAt'),
      participantCount: getInt('participantCount'),
      shareUrl: getStr('shareUrl'),
      accessToken: json['accessToken']?.toString() ?? '',
      liveKitServerUrl: json['liveKitServerUrl']?.toString() ?? '',
      isPublic: getBool('isPublic'),
      churchName: json['churchName'] ?? json['church']?['name'],
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomName': roomName,
      'title': title,
      'description': description,
      'hostName': hostName,
      'hostId': hostId,
      'startedAt': startedAt,
      'participantCount': participantCount,
      'shareUrl': shareUrl,
      'accessToken': accessToken,
      'liveKitServerUrl': liveKitServerUrl,
      'isPublic': isPublic,
      'churchName': churchName,
      'thumbnail': thumbnail,
    };
  }
}

/// Model pour créer une room
class CreateLiveRoomRequest {
  final String roomName;
  final String participantName;
  final int participantId;
  final String title;
  final String description;
  final bool isPublic;

  CreateLiveRoomRequest({
    required this.roomName,
    required this.participantName,
    required this.participantId,
    required this.title,
    required this.description,
    required this.isPublic,
  });

  Map<String, dynamic> toJson() {
    return {
      'roomName': roomName,
      'title': title,
      'description': description,
      'isPublic': isPublic,
    };
  }
}

/// Model pour rejoindre une room
class JoinLiveRoomRequest {
  final String roomName;
  final String participantName;
  final int participantId;
  final String role;

  JoinLiveRoomRequest({
    required this.roomName,
    required this.participantName,
    required this.participantId,
    this.role = 'viewer',
  });

  Map<String, dynamic> toJson() {
    return {
      'roomName': roomName,
      'participantName': participantName,
      'participantId': participantId,
      'role': role,
    };
  }
}

/// Model pour les infos d'une room
class LiveRoomInfo {
  final String roomName;
  final String title;
  final String description;
  final String hostName;
  final int hostId;
  final String startedAt;
  final int participantCount;
  final bool isLive;
  final String shareUrl;
  final String? churchName;
  final String? churchLocation;

  LiveRoomInfo({
    required this.roomName,
    required this.title,
    required this.description,
    required this.hostName,
    required this.hostId,
    required this.startedAt,
    required this.participantCount,
    required this.isLive,
    required this.shareUrl,
    this.churchName,
    this.churchLocation,
  });

  factory LiveRoomInfo.fromJson(Map<String, dynamic> json) {
    return LiveRoomInfo(
      roomName: json['roomName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      hostName: json['hostName'] ?? '',
      hostId: json['hostId'] ?? 0,
      startedAt: json['startedAt'] ?? DateTime.now().toIso8601String(),
      participantCount: json['participantCount'] ?? 0,
      isLive: json['isLive'] ?? false,
      shareUrl: json['shareUrl'] ?? '',
      churchName: json['church']?['name'],
      churchLocation: json['church']?['location'],
    );
  }
}
