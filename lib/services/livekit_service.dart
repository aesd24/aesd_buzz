import 'package:dio/dio.dart';
import 'package:aesd/models/live_model.dart';

class LiveKitService {
  final Dio _dio;
  final String baseUrl;

  LiveKitService({required Dio dio, required this.baseUrl}) : _dio = dio;

  /// Créer une nouvelle room livestream
  Future<LiveRoom> createRoom(CreateLiveRoomRequest request) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/livekit/create-room',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return LiveRoom.fromJson(data);
      } else {
        throw Exception('Failed to create room: ${response.data['error']}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur création room: ${e.message}');
    }
  }

  /// Rejoindre une room existante
  Future<LiveRoom> joinRoom(JoinLiveRoomRequest request) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/livekit/join-room',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return LiveRoom.fromJson(data);
      } else {
        throw Exception('Failed to join room: ${response.data['error']}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur connexion room: ${e.message}');
    }
  }

  /// Terminer un livestream
  Future<Map<String, dynamic>> endRoom({
    required String roomName,
    required int participantId,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/livekit/end-room',
        data: {
          'roomName': roomName,
          'participantId': participantId,
        },
      );

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to end room: ${response.data['error']}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur fin room: ${e.message}');
    }
  }

  /// Mettre en pause/reprendre un livestream
  Future<void> pauseRoom({
    required String roomName,
    required bool isPaused,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/livekit/pause-room',
        data: {
          'roomName': roomName,
          'isPaused': isPaused,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to pause room: ${response.data['error']}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur pause room: ${e.message}');
    }
  }

  /// Lister tous les lives actifs
  Future<List<LiveRoomInfo>> getActiveLives() async {
    try {
      final response = await _dio.get('$baseUrl/api/livekit/rooms');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((room) => LiveRoomInfo.fromJson(room as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch lives: ${response.data['error']}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur récupération lives: ${e.message}');
    }
  }

  /// Obtenir les infos d'une room spécifique
  Future<LiveRoomInfo> getRoomInfo(String roomName) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/livekit/room-info/$roomName',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return LiveRoomInfo.fromJson(data);
      } else {
        throw Exception('Room not found: ${response.data['error']}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur récupération room: ${e.message}');
    }
  }

  /// Enregistrer les stats du spectateur
  Future<void> saveViewerStats({
    required String roomName,
    required int participantId,
    required int watchDuration,
    required String quality,
    required String startedAt,
    required String endedAt,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/livekit/save-viewer-stats',
        data: {
          'roomName': roomName,
          'participantId': participantId,
          'watchDuration': watchDuration,
          'quality': quality,
          'startedAt': startedAt,
          'endedAt': endedAt,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to save stats: ${response.data['error']}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur enregistrement stats: ${e.message}');
    }
  }

  /// Mute/Unmute un participant
  Future<void> muteParticipant({
    required String roomName,
    required int participantId,
    required bool audioMuted,
    required bool videoMuted,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/livekit/mute-participant',
        data: {
          'roomName': roomName,
          'participantId': participantId,
          'audioMuted': audioMuted,
          'videoMuted': videoMuted,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mute participant: ${response.data['error']}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur mute participant: ${e.message}');
    }
  }

  /// Expulser un participant
  Future<void> removeParticipant({
    required String roomName,
    required int participantToRemoveId,
    String? reason,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/livekit/remove-participant',
        data: {
          'roomName': roomName,
          'participantToRemoveId': participantToRemoveId,
          'reason': reason,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to remove participant: ${response.data['error']}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur suppression participant: ${e.message}');
    }
  }

  /// Récupérer l'historique de chat
  Future<List<Map<String, dynamic>>> getChatMessages(
    String roomName, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/livekit/messages/$roomName',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch messages: ${response.data['error']}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur récupération messages: ${e.message}');
    }
  }

  /// Envoyer un message dans le chat
  Future<void> sendChatMessage({
    required String roomName,
    required int participantId,
    required String participantName,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/livekit/send-message',
        data: {
          'roomName': roomName,
          'participantId': participantId,
          'participantName': participantName,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send message: ${response.data['error']}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur envoi message: ${e.message}');
    }
  }

  /// Lister les enregistrements disponibles
  Future<List<Map<String, dynamic>>> getRecordings() async {
    try {
      final response = await _dio.get('$baseUrl/api/livekit/recordings');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch recordings: ${response.data['error']}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur récupération enregistrements: ${e.message}');
    }
  }
}
