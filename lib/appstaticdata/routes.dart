import 'package:aesd/middleware/auth_middleware.dart';
import 'package:aesd/pages/auth/change_password/update_password.dart';
import 'package:aesd/pages/auth/login_register/auth_page.dart';
import 'package:aesd/pages/auth/change_password/forgot_password.dart';
import 'package:aesd/pages/auth/change_password/otp_verification.dart';
import 'package:aesd/pages/auth/login_register/update.dart';
import 'package:aesd/pages/auth/splash_screen.dart';
import 'package:aesd/pages/home.dart';
import 'package:aesd/pages/profil.dart';
import 'package:aesd/pages/forum/subject.dart';
import 'package:aesd/pages/social/new/detail.dart';
import 'package:aesd/pages/social/posts/detail.dart';
import 'package:aesd/pages/wallet/transactions.dart';
import 'package:aesd/pages/wallet/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class Routes {
  static String initial = "/";
  static String homepage = "/homePage";
  static String auth = '/user/auth';
  static String forgot = '/user/forgot';
  static String verifyEmail = '/user/verifyEmail';
  static String changePassword = '/user/updatePassword';
  static String profil = '/user/profil';
  static String wallet = '/wallet';
  static String transactions = '/transactions';
  static String postDetail = '/postDetail';
  static String newsDetail = '/newsDetail';
  static String subject = '/subject';
  static String updateUser = '/user/update';
}

final getPage = [
  GetPage(name: Routes.initial, page: () => SplashScreen()),
  GetPage(name: Routes.homepage, page: _buildLoggedPage(MainPage())),
  GetPage(name: Routes.auth, page: () => AuthPage()),
  GetPage(name: Routes.forgot, page: () => ForgotPasswordPage()),
  GetPage(name: Routes.verifyEmail, page: () => OtpVerificationPage()),
  GetPage(
    name: Routes.changePassword,
    page: () => UpdatePasswordPage(),
  ),
  GetPage(name: Routes.profil, page: _buildLoggedPage(UserProfil())),
  GetPage(name: Routes.transactions, page: _buildLoggedPage(TransactionsPage())),
  GetPage(name: Routes.wallet, page: _buildLoggedPage(Wallet())),
  GetPage(name: Routes.postDetail, page: _buildLoggedPage(PostDetail())),
  GetPage(name: Routes.newsDetail, page: _buildLoggedPage(NewsPage())),
  GetPage(name: Routes.subject, page: _buildLoggedPage(DiscutionSubjectPage())),
  GetPage(name: Routes.updateUser, page: _buildLoggedPage(UpdateUserPage())),
];

Widget Function() _buildLoggedPage(Widget page) {
  return () => AuthMiddleware(child: page);
}
