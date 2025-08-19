import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/provider/auth.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'icon.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Consumer<Auth>(
            builder: (context, provider, child) {
              final user = provider.user!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: "avatar",
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                user.photo != null
                                    ? FastCachedImageProvider(user.photo!)
                                    : null,
                            child:
                                user.photo != null
                                    ? null
                                    : SvgPicture.asset(
                                      "assets/illustrations/user-avatar.svg",
                                    ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          user.name,
                          style: mainTextStyle.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(user.accountType.name, style: mediumGreyTextStyle),
                        if (user.accountType.code == Dictionnary.servant.code)
                          Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              runSpacing: 5,
                              children: [
                                Text("0 Abonnements"),
                                CircleAvatar(
                                  radius: 3,
                                  backgroundColor: notifire.getTextColor1,
                                ),
                                Text("0 Abonnés"),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: Divider(
                        height: 3,
                        radius: BorderRadius.circular(5),
                        color: notifire.getMaingey,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              ListTile(
                                onTap:
                                    () => Get.toNamed(
                                      Routes.profil,
                                      arguments: {'user': provider.user!},
                                    ),
                                leading: cusFaIcon(FontAwesomeIcons.solidUser),
                                title: Text(
                                  "Profil",
                                  style: mediumBlackTextStyle,
                                ),
                              ),
                              ListTile(
                                leading: cusFaIcon(FontAwesomeIcons.church),
                                title: Text(
                                  "Mon église",
                                  style: mediumBlackTextStyle,
                                ),
                              ),
                              ListTile(
                                leading: cusFaIcon(
                                  FontAwesomeIcons.moneyBillTransfer,
                                ),
                                onTap: () => Get.toNamed(Routes.wallet),
                                title: Text(
                                  "Porte-monnaie",
                                  style: mediumBlackTextStyle,
                                ),
                              ),
                              if (provider.user!.accountType.code ==
                                  Dictionnary.servant.code)
                                ListTile(
                                  leading: cusFaIcon(
                                    FontAwesomeIcons.gaugeHigh,
                                  ),
                                  title: Text(
                                    "Dashboard",
                                    style: mediumBlackTextStyle,
                                  ),
                                ),
                              ListTile(
                                leading: cusFaIcon(FontAwesomeIcons.circleInfo),
                                title: Text(
                                  "En savoir plus",
                                  style: mediumBlackTextStyle,
                                ),
                              ),
                              ListTile(
                                leading: cusFaIcon(FontAwesomeIcons.gears),
                                title: Text(
                                  "Préférences",
                                  style: mediumBlackTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: CustomTextButton(
                            onPressed: () {
                              provider.logout();
                              Get.offAllNamed(Routes.auth);
                            },
                            type: ButtonType.error,
                            icon: cusFaIcon(
                              FontAwesomeIcons.arrowRightFromBracket,
                              color: Colors.white,
                            ),
                            label: "Me Deconnecter",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
