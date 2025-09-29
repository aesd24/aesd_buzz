import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/pages/user/retry_certif.dart';
import 'package:aesd/provider/auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'icon.dart';

BannerType? getBannerType(BuildContext context) {
  final user = Provider.of<Auth>(context, listen: false).user;

  if (user == null) return null;

  if (user.certifStatus == CertificationStates.pending) {
    return BannerType.waitingBanner;
  } else if (user.certifStatus == CertificationStates.rejected) {
    return BannerType.rejectedBanner;
  } else {
    return null;
  }
}

PreferredSize? getCertificationBanner(BuildContext context) {
  BannerType? banner = getBannerType(context);

  if (banner == null) return null;

  return PreferredSize(
    preferredSize: Size(double.infinity, 70),
    child: Expanded(
      child: GestureDetector(
        onTap:
            () =>
                banner == BannerType.rejectedBanner
                    ? Get.to(RetryCertifPage())
                    : null,
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: banner.color),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: cusFaIcon(banner.icon, color: banner.color),
            title: Text(
              banner.text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: banner.color),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget getCertificationIcon(BuildContext context) {
  BannerType? banner = getBannerType(context);
  if (banner == null) return SizedBox();

  return GestureDetector(
    onTap:
        () =>
            banner == BannerType.rejectedBanner
                ? Get.to(RetryCertifPage())
                : null,
    child: cusFaIcon(banner.icon, color: banner.color, size: 15),
  );
}

class BannerType {
  final IconData icon;
  final Color color;
  final String text;

  BannerType({required this.icon, required this.color, required this.text});

  static final rejectedBanner = BannerType(
    icon: FontAwesomeIcons.triangleExclamation,
    text:
        "La validation de votre compte à été refusé. Cliquez pour renvoyer vos informations",
    color: notifire.danger,
  );

  static final waitingBanner = BannerType(
    icon: FontAwesomeIcons.solidClock,
    text: "Votre compte est en attente de validation.",
    color: notifire.info,
  );
}
