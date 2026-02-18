import 'package:aesd/services/dio_service.dart';

class NotificationService extends DioClient {
  /// Récupérer toutes les notifications de l'utilisateur
  /// GET /api/notifications
  Future<Map<String, dynamic>> getNotifications() async {
    final client = await getApiClient();
    final response = await client.get('notifications');
    return response.data;
  }

  /// Récupérer le nombre de notifications non lues
  /// GET /api/notifications/unread-count
  Future<int> getUnreadCount() async {
    final client = await getApiClient();
    final response = await client.get('notifications/unread-count');
    return response.data['unread_count'] ?? 0;
  }

  /// Marquer une notification comme lue
  /// POST /api/notifications/{id}/read
  Future<void> markAsRead(int id) async {
    final client = await getApiClient();
    await client.post('notifications/$id/read');
  }

  /// Marquer toutes les notifications comme lues
  /// POST /api/notifications/read-all
  Future<void> markAllAsRead() async {
    final client = await getApiClient();
    await client.post('notifications/read-all');
  }

  /// Supprimer une notification
  /// DELETE /api/notifications/{id}
  Future<void> deleteNotification(int id) async {
    final client = await getApiClient();
    await client.delete('notifications/$id');
  }

  /// Envoyer le token FCM au backend
  /// POST /api/users/fcm-token
  Future<void> updateFCMToken(String token) async {
    try {
      final client = await getApiClient();
      await client.post('users/fcm-token', data: {'token': token});
      print('✅ FCM Token envoyé au backend');
    } catch (e) {
      print('❌ Erreur envoi FCM token: $e');
      rethrow;
    }
  }
}
