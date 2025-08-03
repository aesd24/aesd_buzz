import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/divider.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/pages/auth/login.dart';
import 'package:aesd/pages/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifire!.getbgcolor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // custom TabBar
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: appMainColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: appMainColor,
                    ),
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    tabs: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        child: cusFaIcon(FontAwesomeIcons.arrowRightToBracket)
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        child: cusFaIcon(FontAwesomeIcons.userPlus)
                      ),
                    ]
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: TabBarView(
                    children: [
                      LoginPage(),
                      RegisterPage()
                    ]
                  ),
                ),
                const SizedBox(height: 40),
                textDivider("Or Continue with"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: notifire!.getbgcolor),
                      child: Center(
                          child: SvgPicture.asset(
                            "assets/icons8-facebook 1.svg",
                          )),
                    ),
                    const SizedBox(width: 12,),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: notifire!.getbgcolor),
                      child: Center(
                          child: SvgPicture.asset(
                            "assets/icons8-apple-logo.svg", height: 20,width: 20,
                          )),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: notifire!.getbgcolor),
                      child: Center(
                          child: SvgPicture.asset(
                            "assets/icons8-google 1.svg",
                          )),
                    )
                  ],
                ),
                SizedBox(height: 20),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
