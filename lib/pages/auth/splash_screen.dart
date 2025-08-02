
import 'package:aesd/appstaticdata/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  var selected =0;
  @override
  initState()  {

    super.initState();

     Future.delayed(const Duration(seconds: 3),() {

       Get.offAllNamed(Routes.homepage);

    },);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/applogo.svg",height: 50,width: 50,),
              const SizedBox(width: 12,),
              SvgPicture.asset("assets/Buzz..svg",height: 30,width: 40,),
            ],
          )
        ],
      ),
    );
  }
}
