import 'package:dio/dio.dart';
import 'package:aesd/models/live_model.dart';
import 'package:aesd/services/un_expired_cache.dart';

class LiveKitService {
  final Dio _dio;
  final String baseUrl;

  LiveKitService({required Dio dio, required this.baseUrl}) : _dio = dio {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final authToken = await UnExpiredCache().get(key: 'access_token');
        if (authToken != null && authToken != '') {
          options.headers['Authorization'] = authToken;
        }
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
    ));
    // Also set validateStatus to match app standard
    _dio.options.validateStatus = (status) => status! < 500;
  }

  /// Helper pour extraire les données d'une réponse Dio
  dynamic _extractData(Response response) {
    if (response.data is Map) {
      return response.data['data'] ?? response.data;
    }
    return response.data;
  }

  /// Helper pour extraire un message d'erreur d'une réponse Dio
  String _extractError(Response response) {
    try {
      if (response.data is Map) {
        if (response.data['error'] != null) return response.data['error'].toString();
        if (response.data['message'] != null) return response.data['message'].toString();
        if (response.data['errors'] != null) return response.data['errors'].toString();
      } else if (response.data is List) {
        return response.data.join(", ");
      }
      return "Erreur inconnue (${response.statusCode})";
    } catch (e) {
      return "Erreur parsing erreur: $e";
    }
  }

  /// Créer une nouvelle room livestream
  Future<LiveRoom> createRoom(CreateLiveRoomRequest request) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/livekit/create-room',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _extractData(response);
        if (data is Map<String, dynamic>) {
          return LiveRoom.fromJson(data);
        } else if (data is List && data.isNotEmpty) {
           return LiveRoom.fromJson(data[0] as Map<String, dynamic>);
        }
        throw Exception('Format de données invalide pour la création de room');
      } else {
        throw Exception(_extractError(response));
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
        queryParameters: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = _extractData(response);
        if (data is Map<String, dynamic>) {
          return LiveRoom.fromJson(data);
        }
        throw Exception('Format de données invalide pour rejoindre la room');
      } else {
        throw Exception(_extractError(response));
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
        final data = _extractData(response);
        return data is Map<String, dynamic> ? data : {'success': true};
      } else {
        throw Exception(_extractError(response));
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
        throw Exception(_extractError(response));
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
        final data = _extractData(response);
        if (data is List) {
          return data
              .map((room) => LiveRoomInfo.fromJson(room as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception(_extractError(response));
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
        final data = _extractData(response);
        if (data is Map<String, dynamic>) {
          return LiveRoomInfo.fromJson(data);
        }
        throw Exception('Détails de la room non trouvés');
      } else {
        throw Exception(_extractError(response));
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
        throw Exception(_extractError(response));
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
        throw Exception(_extractError(response));
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
        throw Exception(_extractError(response));
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
        final data = _extractData(response);
        return data is List ? List<Map<String, dynamic>>.from(data) : [];
      } else {
        throw Exception(_extractError(response));
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
        throw Exception(_extractError(response));
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
        final data = _extractData(response);
        return data is List ? List<Map<String, dynamic>>.from(data) : [];
      } else {
        throw Exception(_extractError(response));
      }
    } on DioException catch (e) {
      throw Exception('Erreur récupération enregistrements: ${e.message}');
    }
  }
}
