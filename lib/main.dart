import 'package:aesd/provider/auth.dart';
import 'package:aesd/provider/ceremonies.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/provider/event.dart';
import 'package:aesd/provider/forum.dart';
import 'package:aesd/provider/news.dart';
import 'package:aesd/provider/post.dart';
import 'package:aesd/provider/program.dart';
import 'package:aesd/provider/proviercolors.dart';
import 'package:aesd/provider/quiz.dart';
import 'package:aesd/provider/servant.dart';
import 'package:aesd/provider/singer.dart';
import 'package:aesd/provider/testimony.dart';
import 'package:aesd/services/message.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
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
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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

  void _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  void _handleMessage(RemoteMessage message) async {
    if (message.data.containsKey('id')) {
      switch (message.data['type']) {
        case 'post':
          Get.toNamed(
            Routes.postDetail,
            arguments: {'postId': int.parse(message.data['id'])},
          );
          break;
        case 'event':
          Get.toNamed(
            Routes.eventDetail,
            arguments: {'eventId': int.parse(message.data['id'])},
          );
          break;
        case 'ceremony':
          Get.toNamed(
            Routes.ceremonyDetail,
            arguments: {'ceremonyId': int.parse(message.data['id'])},
          );
          break;
        default:
          break;
      }
    }
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
    _checkInitialMessage();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ColorNotifire()),
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProvider(create: (context) => Church()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
        ChangeNotifierProvider(create: (context) => Forum()),
        ChangeNotifierProvider(create: (context) => Quiz()),
        ChangeNotifierProvider(create: (context) => Event()),
        ChangeNotifierProvider(create: (context) => News()),
        ChangeNotifierProvider(create: (context) => Servant()),
        ChangeNotifierProvider(create: (context) => Singer()),
        ChangeNotifierProvider(create: (context) => Testimony()),
        ChangeNotifierProvider(create: (context) => Ceremonies()),
        ChangeNotifierProvider(create: (context) => ProgramProvider()),
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
