
import 'package:aesd/appstaticdata/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  var selected = 0;
  @override
  initState()  {

    super.initState();

     Future.delayed(const Duration(seconds: 4),() {

       Get.offAllNamed(Routes.auth);

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
                fit: BoxFit.cover
              )
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white70,
                    Colors.white10
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                )
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              "assets/icons/launcher_icon.png",
              height: 150,
              width: 150,
            ),
          )
        ],
      ),
    );
  }
}
