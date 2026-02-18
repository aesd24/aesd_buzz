import 'package:aesd/services/dio_service.dart';

class NotificationRequest extends DioClient {
  final String baseRoute = "notifications";

  /// Récupérer toutes les notifications
  Future getAll({int? page}) async {
    final client = await getApiClient();
    return client.get(
      baseRoute,
      queryParameters: page != null ? {"page": page} : null,
    );
  }

  /// Récupérer une notification spécifique
  Future getOne(int id) async {
    final client = await getApiClient();
    return client.get('$baseRoute/$id');
  }

  /// Marquer une notification comme lue
  Future markAsRead(int id) async {
    final client = await getApiClient();
    return client.post('$baseRoute/$id/read');
  }

  /// Marquer toutes les notifications comme lues
  Future markAllAsRead() async {
    final client = await getApiClient();
    return client.post('$baseRoute/read-all');
  }

  /// Récupérer le compteur de notifications non lues
  Future getUnreadCount() async {
    final client = await getApiClient();
    return client.get('$baseRoute/unread-count');
  }
}


