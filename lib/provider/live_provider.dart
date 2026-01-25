import 'package:flutter/material.dart';
import 'package:aesd/models/live_model.dart';
import 'package:aesd/services/livekit_service.dart';

class LiveProvider extends ChangeNotifier {
  final LiveKitService liveKitService;

  LiveProvider({required this.liveKitService});

  // State variables
  List<LiveRoomInfo> _activeLives = [];
  LiveRoom? _currentRoom;
  bool _isLoading = false;
  String? _error;
  int _participantCount = 0;

  // Getters
  List<LiveRoomInfo> get activeLives => _activeLives;
  LiveRoom? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get participantCount => _participantCount;

  /// Créer une nouvelle room livestream
  Future<LiveRoom?> createLiveRoom({
    required String title,
    required String description,
    required String participantName,
    required int participantId,
    required bool isPublic,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final roomName =
          'live-${DateTime.now().millisecondsSinceEpoch}'; // Unique room name

      final request = CreateLiveRoomRequest(
        roomName: roomName,
        participantName: participantName,
        participantId: participantId,
        title: title,
        description: description,
        isPublic: isPublic,
      );

      _currentRoom = await liveKitService.createRoom(request);
      _isLoading = false;
      notifyListeners();
      return _currentRoom;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Rejoindre une room existante
  Future<LiveRoom?> joinLiveRoom({
    required String roomName,
    required String participantName,
    required int participantId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = JoinLiveRoomRequest(
        roomName: roomName,
        participantName: participantName,
        participantId: participantId,
        role: 'viewer',
      );

      _currentRoom = await liveKitService.joinRoom(request);
      _isLoading = false;
      notifyListeners();
      return _currentRoom;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Récupérer tous les lives actifs
  Future<void> fetchActiveLives() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeLives = await liveKitService.getActiveLives();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtenir les infos d'une room spécifique
  Future<LiveRoomInfo?> getRoomInfo(String roomName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final roomInfo = await liveKitService.getRoomInfo(roomName);
      _isLoading = false;
      notifyListeners();
      return roomInfo;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Terminer un livestream
  Future<bool> endLiveRoom() async {
    if (_currentRoom == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await liveKitService.endRoom(
        roomName: _currentRoom!.roomName,
        participantId: _currentRoom!.hostId,
      );

      _currentRoom = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Mettre en pause/reprendre le livestream
  Future<bool> pauseResumeLive(bool isPaused) async {
    if (_currentRoom == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await liveKitService.pauseRoom(
        roomName: _currentRoom!.roomName,
        isPaused: isPaused,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Enregistrer les stats du spectateur
  Future<bool> saveViewerStats({
    required int watchDuration,
    required String quality,
    required String startedAt,
  }) async {
    if (_currentRoom == null) return false;

    try {
      await liveKitService.saveViewerStats(
        roomName: _currentRoom!.roomName,
        participantId: _currentRoom!.hostId,
        watchDuration: watchDuration,
        quality: quality,
        startedAt: startedAt,
        endedAt: DateTime.now().toIso8601String(),
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Mute/Unmute audio
  Future<bool> muteAudio(bool mute) async {
    if (_currentRoom == null) return false;

    try {
      await liveKitService.muteParticipant(
        roomName: _currentRoom!.roomName,
        participantId: _currentRoom!.hostId,
        audioMuted: mute,
        videoMuted: false,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Mute/Unmute vidéo
  Future<bool> muteVideo(bool mute) async {
    if (_currentRoom == null) return false;

    try {
      await liveKitService.muteParticipant(
        roomName: _currentRoom!.roomName,
        participantId: _currentRoom!.hostId,
        audioMuted: false,
        videoMuted: mute,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Récupérer les messages du chat
  Future<List<Map<String, dynamic>>> fetchChatMessages(String roomName) async {
    try {
      return await liveKitService.getChatMessages(roomName);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  /// Envoyer un message au chat
  Future<bool> sendChatMessage({
    required String roomName,
    required int participantId,
    required String participantName,
    required String message,
  }) async {
    try {
      await liveKitService.sendChatMessage(
        roomName: roomName,
        participantId: participantId,
        participantName: participantName,
        message: message,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Récupérer les enregistrements
  Future<List<Map<String, dynamic>>> fetchRecordings() async {
    try {
      return await liveKitService.getRecordings();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  /// Nettoyer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Réinitialiser
  void reset() {
    _activeLives = [];
    _currentRoom = null;
    _isLoading = false;
    _error = null;
    _participantCount = 0;
    notifyListeners();
  }
}
