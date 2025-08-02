// ignore_for_file: deprecated_member_use



import 'package:aesd/provider/proviercolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart'hide Trans;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aesd/appstaticdata/staticdata.dart';

class SingUpPage extends StatefulWidget {
  const SingUpPage({Key? key}) : super(key: key);

  @override
  State<SingUpPage> createState() => _SingUpPageState();
}

class _SingUpPageState extends State<SingUpPage> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<ColorNotifire>(
          builder: (context, value, child) => Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: notifire!.getprimerycolor,
            child: DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if (constraints.maxWidth < 600) {
                    // Mobile layout
                    return Container(
                      color: notifire!.getbgcolor,
                      height: 900,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildlogin(width: constraints.maxWidth)
                          ],
                        ),
                      ),
                    );
                  } else if (constraints.maxWidth < 1200) {
                    return  Container(
                      color: constraints.maxWidth<860? notifire!.getbgcolor:notifire!.getprimerycolor,
                      height: 1000,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            constraints.maxWidth<860? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 80),
                              child: _buildlogin(width: constraints.maxWidth),
                            ):
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 19,vertical: 80),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 782,
                                        decoration:  BoxDecoration(
                                          color: notifire!.getbgcolor,
                                          borderRadius:
                                          const BorderRadius.all(Radius.circular(37)),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child:_buildlogin(width: constraints.maxWidth),
                                            ),
                                            Expanded(
                                              child: buildqrcode(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Website layout
                    return SizedBox(
                      height: 1000,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80,vertical: 80),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 782,
                                        decoration:  BoxDecoration(
                                          color: notifire!.getbgcolor,
                                          borderRadius:
                                          const BorderRadius.all(Radius.circular(37)),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child:_buildlogin(width: constraints.maxWidth),
                                            ),
                                            Expanded(
                                              child: buildqrcode(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }





  Widget _buildlogin({required double width}) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
        child: Container(
          height: 734,
          decoration:  BoxDecoration(
            color: notifire!.getprimerycolor,
            borderRadius: const BorderRadius.all(Radius.circular(37)),
          ),
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: width<600?20:50.0,vertical: width<600?40:50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 SizedBox(
                  height: 110,
                  child: TabBarView(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create Your Account",
                          style: mainTextStyle.copyWith(overflow: TextOverflow.ellipsis,color: notifire!.getMainText),
                          maxLines: 2,
                        ),
                         Text( "Setting up an account takes less than 1 minute.",
                            style: mediumGreyTextStyle.copyWith(fontSize: 16),
                            maxLines: 2),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome back",
                            style: mainTextStyle.copyWith(overflow: TextOverflow.ellipsis,color: notifire!.getMainText),
                            maxLines: 2),
                        const SizedBox(height: 3,),
                        Text('Please Enter your email and password',
                            style: mediumGreyTextStyle.copyWith(fontSize: 16),
                            maxLines: 2),
                      ],
                    )
                  ]),
                ),
                const SizedBox(
                  height: 21,
                ),
                Container(
                  height: 50,
                  width: 180,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: notifire!.getbgcolor,
                      borderRadius: BorderRadius.circular(20)),
                  child: TabBar(
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: appMainColor,
                      ),
                      dividerColor: Colors.transparent,
                      unselectedLabelColor: notifire!.getMainText
                      ,
                      tabs: const [
                        Text('Login'),
                        Text('SignUp',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 14)),
                      ]),
                ),
                const SizedBox(
                  height: 26.8,
                ),
                Flexible(
                  child: TabBarView(
                      children: [
                    Column(
                      children: [
                        buildTextFilde(
                            hinttext: "Email Address",
                            prefixicon: "assets/at.svg",
                            suffixistrue: true,
                            suffix: 'assets/octagon-check.svg'),
                        const SizedBox(
                          height: 19.8,
                        ),
                        buildTextFilde(
                          hinttext: "Password",
                          prefixicon: "assets/lock.svg",
                          suffixistrue: false,
                        ),
                        const SizedBox(
                          height: 19.8,
                        ),
                        buildTextFilde(
                          hinttext: "Referral code (Optional)",
                          prefixicon: "assets/user-change.svg",
                          suffixistrue: false,
                        ),
                        const SizedBox(
                          height: 27.3,
                        ),
                        ElevatedButton(
                            onPressed: () {
                            },
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                backgroundColor: appMainColor,
                                elevation: 0,
                                fixedSize: const Size.fromHeight(60)),
                            child: Row(
                              children: [
                                const Expanded(
                                    child: SizedBox(
                                  width: 10,
                                )),
                                 Text(
                                  "Continue",
                                  style: mediumBlackTextStyle.copyWith(color: Colors.white)
                                ),
                                const Expanded(
                                    child: SizedBox(
                                  width: 10,
                                )),
                                Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Center(
                                      child: SvgPicture.asset(
                                    "assets/arrow-right-small.svg",
                                    width: 12,
                                    height: 12,
                                    color: Colors.white,
                                  )),
                                ),
                              ],
                            )),
                        const SizedBox(
                          height: 46,
                        ),
                         Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             SizedBox(
                                width: 40,
                                child: Divider(
                                  color: notifire!.getMainText,
                                  height: 20,
                                  thickness: 1,
                                )),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Or Continue with",
                              style: mediumBlackTextStyle.copyWith(color: notifire!.getMainText),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                             SizedBox(
                                width: 40,
                                child: Divider(
                                  color: notifire!.getMainText,
                                  height: 20,
                                  thickness: 1,
                                )),
                          ],
                        ),
                        const SizedBox(height: 17.5,),
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
                                    "assets/icons8-apple-logo.svg",color: notifire!.getTextColor1,height: 20,width: 20,
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
                                    "assets/icons8-google 1.svg",
                                  )),
                            )
                          ],
                        )
                      ],
                    ),
                        Column(
                          children: [
                            buildTextFilde(
                                hinttext: "Email Address",
                                prefixicon: "assets/at.svg",
                                suffixistrue: true,
                                suffix: 'assets/octagon-check.svg'),
                            const SizedBox(
                              height: 19.8,
                            ),
                            buildTextFilde(
                              hinttext: "Password",
                              prefixicon: "assets/lock.svg",
                              suffixistrue: false,
                            ),
                            const SizedBox(
                              height: 19.8,
                            ),
                            buildTextFilde(
                              hinttext: "Referral code (Optional)",
                              prefixicon: "assets/user-change.svg",
                              suffixistrue: false,
                            ),
                            const SizedBox(
                              height: 27.3,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24)),
                                    backgroundColor: appMainColor,
                                    elevation: 0,
                                    fixedSize: const Size.fromHeight(60)),
                                child: Row(
                                  children: [
                                    const Expanded(
                                        child: SizedBox(
                                          width: 10,
                                        )),
                                     Text(
                                      "Continue",
                                      style: mediumBlackTextStyle.copyWith(color: Colors.white),
                                    ),
                                    const Expanded(
                                        child: SizedBox(
                                          width: 10,
                                        )),
                                    Container(
                                      height: 35,
                                      width: 35,
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12)),
                                      child: Center(
                                          child: SvgPicture.asset(
                                            "assets/arrow-right-small.svg",
                                            width: 12,
                                            height: 12,
                                            color: Colors.white,
                                          )),
                                    ),
                                  ],
                                )),
                            const SizedBox(
                              height: 46,
                            ),
                             Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                 SizedBox(
                                    width: 40,
                                    child: Divider(
                                      color: notifire!.getMainText,
                                      height: 20,
                                      thickness: 1,
                                    )),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Or Continue with",
                                  style: mediumBlackTextStyle.copyWith(color: notifire!.getMainText),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                 SizedBox(
                                    width: 40,
                                    child: Divider(
                                      color: notifire!.getMainText,
                                      height: 20,
                                      thickness: 1,
                                    )),
                              ],
                            ),
                            const SizedBox(height: 17.5,),
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
                                        "assets/icons8-apple-logo.svg",color: notifire!.getTextColor1,height: 20,width: 20,
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
                                        "assets/icons8-google 1.svg",
                                      )),
                                )
                              ],
                            )
                          ],
                        ),
                      ]
                    ),
                  )
                ],
              ),
            ),
        ));
  }
}

Widget buildqrcode(){

  return Consumer<ColorNotifire>(
    builder: (context, value, child) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 600,
        color: notifire!.getbgcolor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 191,
              width: 191,
              child: SvgPicture.asset('assets/Group 1000000834.svg'),
            ),
            const SizedBox(height: 33,),


            Text("Login With QR code",style: mainTextStyle.copyWith(color: notifire!.getMainText),),
            const SizedBox(height: 4,),
            RichText(
                text:
                TextSpan(
                    children: [
                      TextSpan(text: "Scan QR code with ",style: mediumBlackTextStyle.copyWith(color: notifire!.getMainText)),
                      TextSpan(text: "app",style: mediumBlackTextStyle.copyWith(color: appMainColor)),

                    ])),
            const SizedBox(height: 33,),

            Container(
              height: 34,
              width: 234,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: notifire!.getprimerycolor,
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    height: 24,
                    width: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: appMainColor,
                    ),
                    child: Center(child: SvgPicture.asset("assets/lock.svg",color: Colors.white,height: 16,width: 16,)),
                  ),
                  const SizedBox(width: 10,),
                  InkWell(
                    onTap: () {
                      _launchUrl();
                    },
                    child: RichText(
                        text:
                        TextSpan(
                            children: [
                              TextSpan(text: "https:",style: mediumBlackTextStyle.copyWith(fontSize: 14,fontWeight: FontWeight.w400,color: appMainColor)),
                              TextSpan(text: "//mywebsiteurl.com",style: mediumBlackTextStyle.copyWith(fontWeight: FontWeight.w400,fontSize: 14,color: notifire!.getTextColor1)),

                            ])),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 60,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text("The Perfect Admin Panel For Your Business! Enjoy",style: mediumGreyTextStyle.copyWith(fontWeight: FontWeight.w400,fontSize: 15,),textAlign: TextAlign.center,),
            )
          ],
        ),
      ),
    ),
  );
}
Future<void> _launchUrl() async {
  var url = "https://www.bybit.com/en-US/";
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}
Widget buildTextFilde(
    {required String hinttext,
      required String prefixicon,
      String? suffix,
      required bool suffixistrue}) {
  return TextField(
    style: TextStyle( color: notifire!.getMainText),
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide:  BorderSide(color: notifire!.isDark?   notifire!.geticoncolor  :Colors.grey.shade200)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide:  BorderSide(color: notifire!.isDark?   notifire!.geticoncolor  :Colors.grey.shade200)),
      hintText: hinttext,
      hintStyle: mediumGreyTextStyle,
      prefixIcon: SizedBox(
        height: 20,
        width: 50,
        child: Center(
            child: SvgPicture.asset(
              prefixicon,
              height: 18,
              width: 18,
              color: notifire!.geticoncolor ,
            )),
      ),
      suffixIcon: suffixistrue
          ? SizedBox(
        height: 20,
        width: 50,
        child: Center(
            child: SvgPicture.asset(
              suffix!,
              height: 18,
              width: 18,
              color: notifire!.geticoncolor ,
            )),
      )
          : const SizedBox(),
    ),
  );
}
