import 'package:aesd/provider/auth.dart';
import 'package:aesd/provider/ceremonies.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/provider/cinetpay.dart';
import 'package:aesd/provider/event.dart';
import 'package:aesd/provider/forum.dart';
import 'package:aesd/provider/live_provider.dart';
import 'package:aesd/provider/news.dart';
import 'package:aesd/provider/notification.dart';
import 'package:aesd/provider/post.dart';
import 'package:aesd/provider/program.dart';
import 'package:aesd/provider/proviercolors.dart';
import 'package:aesd/provider/quiz.dart';
import 'package:aesd/provider/servant.dart';
import 'package:aesd/provider/singer.dart';
import 'package:aesd/provider/testimony.dart';
import 'package:aesd/provider/user.dart';
import 'package:aesd/provider/wallet_provider.dart';
import 'package:aesd/services/livekit_service.dart';
import 'package:aesd/services/message.dart';
import 'package:aesd/services/fcm_service.dart';
import 'package:dio/dio.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'appstaticdata/routes.dart';
import 'appstaticdata/staticdata.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class OpenedByNotificationResponse {
  OpenedByNotificationResponse({
    required this.response,
    required this.notification,
  });

  bool response;
  RemoteMessage? notification;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Charger les variables d'environnement (optionnel)
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Fichier .env chargé avec succès');
  } catch (e) {
    print('⚠️ Impossible de charger .env: $e');
    print('⚠️ L\'application continuera sans variables d\'environnement');
  }
  
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialiser le service de notifications (Token, Canal, Permissions)
  try {
    await FCMService().initialize();
    print('✅ Service FCM initialisé');
  } catch (e) {
    print('❌ Erreur initialisation FCM Service: $e');
  }

  await initializeDateFormatting('fr_FR', null);
  await FastCachedImageConfig.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final scaffoldMessengerKey = MessageService.getScaffoldMessengerKey();

  // Cache pour éviter les doublons de notifications
  final Set<String> _notificationIds = {};

  void _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  /// Handler pour les messages Firebase
  /// - message : Message Firebase reçu
  /// - isFromNotification : true si vient d'une notification (clic), false si message en app
  void _handleMessage(RemoteMessage message, {bool isFromNotification = false}) async {
    print('Notification reçue: ${message.data}');
    
    // Éviter les doublons (vérifier l'ID de notification)
    String notificationId = message.messageId ?? message.sentTime.toString();
    if (_notificationIds.contains(notificationId) && isFromNotification) {
      print('Notification déjà traitée: $notificationId');
      return;
    }
    _notificationIds.add(notificationId);

    // Vider le cache après 5 secondes pour éviter les énormes fuites mémoire
    Future.delayed(Duration(seconds: 5), () {
      _notificationIds.remove(notificationId);
    });

    if (message.data.isEmpty) {
      return;
    }

    try {
      final type = message.data['type'] as String?;
      final id = message.data['id'] as String?;

      if (id == null || type == null) {
        return;
      }

      // Redirection vers la page appropriée
      switch (type) {
        case 'post':
          Get.toNamed(
            Routes.postDetail,
            arguments: {'postId': int.parse(id)},
          );
          break;
        case 'event':
          Get.toNamed(
            Routes.eventDetail,
            arguments: {'eventId': int.parse(id)},
          );
          break;
        case 'ceremony':
          Get.toNamed(
            Routes.ceremonyDetail,
            arguments: {'ceremonyId': int.parse(id)},
          );
          break;
        case 'quiz':
          Get.toNamed(
            Routes.postDetail,
            arguments: {'postId': int.parse(id)},
          );
          break;
        case 'forum':
          Get.toNamed(
            Routes.subject,
            arguments: {'subjectId': int.parse(id)},
          );
          break;
        default:
          print('Type de notification inconnu: $type');
          break;
      }
    } catch (e) {
      print('Erreur lors du traitement de la notification: $e');
    }
  }

  /// Initialiser les listeners Firebase Messaging
  void _initializeFirebaseMessaging() {
    // 1. Message reçu en foreground (app au premier plan)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message en foreground: ${message.data}');
      _handleMessage(message, isFromNotification: false);
      
      // Optionnel: Afficher une snackbar pour les notifications en avant-plan
      // MessageService.showInfoMessage(message.notification?.title ?? 'Nouvelle notification');
    });

    // 2. Notification cliquée (app en arrière-plan ou fermée, puis clic sur notif)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App ouvert via notification: ${message.data}');
      _handleMessage(message, isFromNotification: true);
    });

    // 3. Message initial au lancement de l'app
    _checkInitialMessage();
  }

  OpenedByNotificationResponse appOpenedByNotification() {
    bool openedByNotification = false;
    RemoteMessage? notification;
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      openedByNotification = true;
      notification = message;
    });
    return OpenedByNotificationResponse(
      response: openedByNotification,
      notification: notification,
    );
  }

  @override
  void initState() {
    super.initState();
    // _initializeFirebaseMessaging(); // Géré par FCMService
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ColorNotifire()),
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => Church()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
        ChangeNotifierProvider(create: (context) => Forum()),
        ChangeNotifierProvider(create: (context) => Quiz()),
        ChangeNotifierProvider(create: (context) => Event()),
        ChangeNotifierProvider(create: (context) => News()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(
          create: (context) => LiveProvider(
            liveKitService: LiveKitService(
              dio: Dio(BaseOptions(
                baseUrl: "https://monapi.eglisesetserviteursdedieu.com/api/",
              )),
              baseUrl: 'https://monapi.eglisesetserviteursdedieu.com',
            ),
          ),
        ),
        ChangeNotifierProvider(create: (context) => Servant()),
        ChangeNotifierProvider(create: (context) => Singer()),
        ChangeNotifierProvider(create: (context) => Testimony()),
        ChangeNotifierProvider(create: (context) => Ceremonies()),
        ChangeNotifierProvider(create: (context) => ProgramProvider()),
        ChangeNotifierProvider(create: (context) => CinetPay()),
        ChangeNotifierProvider(create: (context) => WalletProvider()),
      ],
      child: GetMaterialApp(
        locale: const Locale('fr', 'FR'),
        translations: AppTranslations(),
        scrollBehavior: MyCustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        initialRoute: Routes.initial,
        getPages: getPage,
        title: 'Aesd',
        theme: ThemeData(
          brightness: notifire.isDark ? Brightness.dark : Brightness.light,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          fontFamily: "Gilroy",
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            brightness: notifire.isDark ? Brightness.dark : Brightness.light,
            primary: const Color(0xFF15BB00),
            surface: notifire.getbgcolor,
          ),
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {'enter_mail': 'Enter your email'},
    'ur_PK': {'enter_mail': 'اپنا ای میل درج کریں۔'},
  };
}
