// ignore_for_file: prefer_const_constructors
import 'package:aesd/pages/auth/login_register/auth_page.dart';
import 'package:aesd/pages/auth/forgot_password.dart';
import 'package:aesd/pages/auth/login_register/login.dart';
import 'package:aesd/pages/auth/otp_verification.dart';
import 'package:aesd/pages/auth/splash_screen.dart';
import 'package:aesd/pages/auth/update_password.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Routes {
  static String initial = "/";
  static String homepage = "/homePage";
  static String auth = '/auth';
  static String login = '/login';
  static String forgot = '/forgot';
  static String verifyEmail = '/verifyEmail';
  static String changePassword = '/updatePassword';
}

final getPage = [
  GetPage(name: Routes.initial, page: () => SplashScreen()),
  GetPage(
    name: Routes.homepage,
    page: () => Scaffold(appBar: AppBar(title: Text("Home page"))),
  ),
  GetPage(name: Routes.auth, page: () => AuthPage()),
  GetPage(name: Routes.login, page: () => LoginPage()),
  GetPage(name: Routes.forgot, page: () => ForgotPasswordPage()),
  GetPage(
    name: Routes.verifyEmail,
    page: () => OtpVerificationPage(),
  ),
  GetPage(name: Routes.changePassword, page: () => UpdatePasswordPage())
];
