import 'dart:io';
import 'package:aesd/models/notification.dart';
import 'package:aesd/requests/notification_request.dart';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRequest _request = NotificationRequest();
  
  final List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  /// Récupérer toutes les notifications
  Future<void> getAll({int? page}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _request.getAll(page: page);
      
      if (response.statusCode == 200) {
        _notifications.clear();
        
        // Gérer différents formats de réponse
        List<dynamic> data;
        if (response.data is Map && response.data.containsKey('data')) {
          data = response.data['data'] as List;
          // Récupérer le compteur si disponible
          if (response.data.containsKey('unread_count')) {
            _unreadCount = response.data['unread_count'] ?? 0;
          }
        } else if (response.data is List) {
          data = response.data as List;
        } else if (response.data is Map && response.data.containsKey('notifications')) {
          // Format alternatif avec clé 'notifications'
          data = response.data['notifications'] as List;
        } else {
          data = [];
        }

        for (var item in data) {
          try {
            _notifications.add(NotificationModel.fromJson(item));
          } catch (e) {
            print('Erreur lors du parsing d\'une notification: $e');
            // Continuer avec les autres notifications
          }
        }
      } else {
        throw HttpException(
          response.data['message'] ?? 'Impossible de charger les notifications'
        );
      }
    } catch (e) {
      // Ne pas rethrow pour éviter de casser l'UI
      print('Erreur lors du chargement des notifications: $e');
      // Garder les notifications précédentes en cas d'erreur
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer le compteur de notifications non lues
  Future<void> getUnreadCount() async {
    try {
      final response = await _request.getUnreadCount();
      
      if (response.statusCode == 200) {
        if (response.data is Map && response.data.containsKey('count')) {
          _unreadCount = response.data['count'] ?? 0;
        } else if (response.data is int) {
          _unreadCount = response.data;
        } else if (response.data is Map && response.data.containsKey('unread_count')) {
          _unreadCount = response.data['unread_count'] ?? 0;
        }
        notifyListeners();
      }
    } catch (e) {
      // Silencieux, on garde la valeur précédente
      // Ne pas afficher d'erreur si l'endpoint n'existe pas encore
      print('Erreur lors de la récupération du compteur: $e');
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(int id) async {
    try {
      final response = await _request.markAsRead(id);
      
      if (response.statusCode == 200) {
        // Mettre à jour localement
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index].readed = true;
          if (_unreadCount > 0) {
            _unreadCount--;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      final response = await _request.markAllAsRead();
      
      if (response.statusCode == 200) {
        // Mettre à jour localement
        for (var notification in _notifications) {
          notification.readed = true;
        }
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Rafraîchir les notifications et le compteur
  Future<void> refresh() async {
    await Future.wait([
      getAll(),
      getUnreadCount(),
    ]);
  }
}

