/// Model pour les données LiveKit
class LiveRoom {
  final String roomName;
  final String title;
  final String description;
  final String hostName;
  final int hostId;
  final String startedAt;
  final int participantCount;
  final String shareUrl;
  final String accessToken;
  final String liveKitServerUrl;
  final bool isPublic;
  final String? churchName;
  final String? thumbnail;

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

  factory LiveRoom.fromJson(Map<String, dynamic> json) {
    return LiveRoom(
      roomName: json['roomName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      hostName: json['hostName'] ?? '',
      hostId: json['hostId'] ?? 0,
      startedAt: json['startedAt'] ?? DateTime.now().toIso8601String(),
      participantCount: json['participantCount'] ?? 0,
      shareUrl: json['shareUrl'] ?? '',
      accessToken: json['accessToken'] ?? '',
      liveKitServerUrl: json['liveKitServerUrl'] ?? '',
      isPublic: json['isPublic'] ?? true,
      churchName: json['churchName'],
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
      'participantName': participantName,
      'participantId': participantId,
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
