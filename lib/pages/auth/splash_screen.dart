import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/provider/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // 🚀 MODE DÉVELOPPEMENT : Bypass l'authentification
  final bool BYPASS_AUTH = true; // Mets à false pour réactiver l'auth

  void init() async {
    try {
      // Si mode développement, skip l'authentification
      if (BYPASS_AUTH) {
        print("⚠️ MODE DEV : Authentification bypass");
        Get.offNamed(Routes.homepage);
        return;
      }

      // Mode normal : vérifier l'authentification
      await Provider.of<Auth>(context, listen: false).isLoggedIn().then((value) {
        print(value);
        if (value) {
          Get.offNamed(Routes.homepage);
        } else {
          Get.offNamed(Routes.auth);
        }
      });
    } catch (e) {
      print("Erreur auth: $e");
      Get.offNamed(Routes.auth);
    }
  }

  @override
  initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () async {
      init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg-1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white70, Colors.white10],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/icons/launcher_icon.png",
                  height: 150,
                  width: 150,
                ),
                if (BYPASS_AUTH) ...[
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade600),
                    ),
                    child: Text(
                      "🔧 MODE DÉVELOPPEMENT",
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}