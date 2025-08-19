// ignore_for_file: prefer_const_constructors
import 'package:aesd/middleware/auth_middleware.dart';
import 'package:aesd/pages/auth/login_register/auth_page.dart';
import 'package:aesd/pages/auth/forgot_password.dart';
import 'package:aesd/pages/auth/login_register/login.dart';
import 'package:aesd/pages/auth/otp_verification.dart';
import 'package:aesd/pages/auth/splash_screen.dart';
import 'package:aesd/pages/auth/update_password.dart';
import 'package:aesd/pages/home.dart';
import 'package:aesd/pages/profil.dart';
import 'package:aesd/pages/wallet/transactions.dart';
import 'package:aesd/pages/wallet/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class Routes {
  static String initial = "/";
  static String homepage = "/homePage";
  static String auth = '/auth';
  static String forgot = '/forgot';
  static String verifyEmail = '/verifyEmail';
  static String changePassword = '/updatePassword';
  static String profil = '/profil';
  static String wallet = '/wallet';
  static String transactions = '/transactions';
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
];

Widget Function() _buildLoggedPage(Widget page) {
  return () => AuthMiddleware(child: page);
}
