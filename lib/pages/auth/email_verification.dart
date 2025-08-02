// ignore_for_file: deprecated_member_use


import 'package:aesd/pages/auth/singup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

import 'package:aesd/appstaticdata/staticdata.dart';
import 'forgot_password.dart';





class EmailVerification extends StatefulWidget {
  const EmailVerification({Key? key}) : super(key: key);

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
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
                          _buildemailverification(width: constraints.maxWidth)
                        ],
                      ),
                    ),
                  );
                } else if (constraints.maxWidth < 1200) {
                  return  Container(
                    color:constraints.maxWidth<680? notifire!.getbgcolor:notifire!.getprimerycolor,
                    height: 1000,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          constraints.maxWidth<680? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 80),
                            child: _buildemailverification(width: constraints.maxWidth),
                          ):
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28,vertical: 80),
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
                                            child:_buildemailverification(width: constraints.maxWidth),
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
                                            child:_buildemailverification(width: constraints.maxWidth),
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
    );
  }

  TextEditingController textEditingController = TextEditingController();

  Widget _buildemailverification({required double width}) {

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
        child: Container(
          height: 734,
          decoration:  BoxDecoration(
            color: notifire!.getprimerycolor,
            borderRadius: const BorderRadius.all(Radius.circular(37)),
          ),
          child:  Padding(
            padding:  EdgeInsets.symmetric(horizontal: width<835?20:50.0,vertical:50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  "Email Verification",
                  style: mainTextStyle.copyWith(overflow: TextOverflow.ellipsis,color: notifire!.getMainText),
                  maxLines: 2,
                ),
                const SizedBox(height: 5,),
                 Text('Please enter the 4-digit verification code that was sent to your email',
                    style: mediumGreyTextStyle.copyWith(fontSize: 16),
                    maxLines: 2),
                const SizedBox(height: 64,),
                 Text(
                  "Send Verification Code to :",
                  style: mediumBlackTextStyle.copyWith(fontSize: 16,color: notifire!.getMainText),
                  maxLines: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                     Text('example@mail.com',
                        style: mediumGreyTextStyle.copyWith(fontSize: 16),
                        maxLines: 2),
                    const SizedBox(width: 10,),
                    
                    SvgPicture.asset("assets/pen-line.svg",width: 16,height: 16,color: const Color(0xffB8BABF),)
                  ],
                ),
                const SizedBox(height: 42,),
                OTPTextField(
                  length: 4,
                   width: MediaQuery.of(context).size.width,
                  fieldWidth: 50,
                  style: const TextStyle(
                      fontSize: 17,color: Colors.white
                  ),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  otpFieldStyle: OtpFieldStyle(
                      backgroundColor: notifire!.getbgcolor,
                      enabledBorderColor: notifire!.getbgcolor,
                      disabledBorderColor: notifire!.getbgcolor,
                      borderColor: notifire!.getbgcolor),
                  fieldStyle: FieldStyle.box,
                  onCompleted: (pin) {

                  },
                ),
                const SizedBox(height: 72,),

                ElevatedButton(
                    onPressed: () {
                      Get.to(const ForgotPassword());
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
                          style: mediumGreyTextStyle.copyWith(color: Colors.white),
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
              ],
            ),
          ),
        )
    );
  }
}
