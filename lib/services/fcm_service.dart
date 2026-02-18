import 'dart:convert';
import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/services/dio_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// Service de gestion des notifications Firebase Cloud Messaging
class FCMService extends DioClient {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialiser FCM et écouter les notifications
  Future<void> initialize() async {
    try {
      // 1. Demander permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Permission notifications accordée');

        // 2. Configurer canal Android
        await _configureLocalNotifications();

        // 3. Récupérer et envoyer token au backend
        final token = await _messaging.getToken();
        if (token != null) {
          // await _sendTokenToBackend(token); // Géré par le backend au login
          print('✅ FCM Token généré: ${token.substring(0, 20)}...');
        }

        // 4. Écouter rafraîchissement token
        _messaging.onTokenRefresh.listen((token) {
           print('🔄 FCM Token rafraîchi: ${token.substring(0, 20)}...');
           // _sendTokenToBackend(token); // Géré par le backend au login
        });

        // 5. Gérer notifications en foreground
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // 6. Gérer tap sur notification (app fermée/background)
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // 7. Vérifier si app ouverte via notification
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
      } else {
        print('❌ Permission notifications refusée');
      }
    } catch (e) {
      print('❌ Erreur initialisation FCM: $e');
    }
  }

  /// Configurer canal de notifications Android
  Future<void> _configureLocalNotifications() async {
    const channel = AndroidNotificationChannel(
      'aesd_default', // ID doit matcher AndroidManifest.xml
      'Notifications AESD',
      description: 'Notifications des posts, événements et demandes',
      importance: Importance.high,
      showBadge: true,
      playSound: true,
    );

    // Créer canal Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialiser plugin
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_notification'),
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _handlePayload(details.payload!);
        }
      },
    );
  }

  /// Envoyer token FCM au backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final client = await getApiClient();
      await client.post('users/fcm-token', data: {'token': token});
      print('✅ FCM Token envoyé: ${token.substring(0, 20)}...');
    } catch (e) {
      print('❌ Erreur envoi token: $e');
    }
  }

  /// Gérer notification reçue quand app en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    print('🔔 Notification reçue (foreground): ${message.notification?.title}');
    _showLocalNotification(message);
  }

  /// Afficher notification locale
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'aesd_default',
      'Notifications AESD',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Nouvelle notification',
      message.notification?.body ?? '',
      details,
      payload: jsonEncode(message.data),
    );
  }

  /// Gérer tap sur notification
  void _handleNotificationTap(RemoteMessage message) {
    print('👆 Tap sur notification: ${message.data}');
    _handlePayload(jsonEncode(message.data));
  }

  /// Naviguer selon type de notification
  void _handlePayload(String payloadJson) {
    try {
      final data = jsonDecode(payloadJson);
      final type = data['type']?.toString() ?? '';
      final postId = data['post_id'];

      print('🧭 Navigation: type=$type, post_id=$postId');

      switch (type) {
        case 'post':
          if (postId != null) {
            Get.toNamed(Routes.postDetail, arguments: {'postId': postId});
          }
          break;

        case 'event':
          if (postId != null) {
            Get.toNamed(Routes.eventDetail, arguments: {'eventId': postId});
          }
          break;

        case 'ceremony':
          if (postId != null) {
            Get.toNamed(Routes.ceremonyDetail,
                arguments: {'ceremonyId': postId});
          }
          break;

        case 'membership_request':
          // Rediriger vers page demandes adhésion
          Get.toNamed(Routes.membershipRequests);
          break;

        case 'donation':
          // Rediriger vers wallet
          Get.toNamed(Routes.wallet);
          break;

        default:
          // Notification générique, ouvrir liste notifications
          Get.toNamed(Routes.notifications);
          break;
      }
    } catch (e) {
      print('❌ Erreur navigation notification: $e');
    }
  }

  /// Supprimer token lors de la déconnexion
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      print('✅ Token FCM supprimé');
    } catch (e) {
      print('❌ Erreur suppression token: $e');
    }
  }
}
