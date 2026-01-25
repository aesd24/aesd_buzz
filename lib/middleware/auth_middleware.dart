import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AuthMiddleware extends StatefulWidget {
  const AuthMiddleware({super.key, required this.child});

  final Widget child;

  @override
  State<AuthMiddleware> createState() => _AuthMiddlewareState();
}

class _AuthMiddlewareState extends State<AuthMiddleware> {
  bool _isLoading = false;

  Future<void> _checkAuth() async {
    try {
      setState(() {
        _isLoading = true;
      });
      bool isLoggedIn = await Provider.of<Auth>(context, listen: false).isLoggedIn();
      if (isLoggedIn) {
        // Charger les données utilisateur
        try {
          await Provider.of<Auth>(context, listen: false).getUserData();
        } catch (e) {
          print("Erreur lors du chargement des données utilisateur: $e");
        }
      }
    } catch (e) {
      e.printError();
      MessageService.showInfoMessage("Connectez-vous pour continuer !");
      Get.offAllNamed(Routes.auth);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: appMainColor,
            strokeWidth: 1.5,
          ),
        ),
      );
    } else {
      return widget.child;
    }
  }
}
