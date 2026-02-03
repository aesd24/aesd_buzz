import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/church_banner.dart';
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

  if (user.accountType == Dictionnary.servant) {
    if (user.certifStatus == CertificationStates.pending) {
      return BannerType.waitingBanner;
    } else if (user.certifStatus == CertificationStates.rejected) {
      return BannerType.rejectedBanner;
    }
  }
  return null;
}

Widget? getCertificationBanner(BuildContext context) {
  BannerType? banner = getBannerType(context);

  if (banner != null) {
    return GestureDetector(
      onTap:
          () =>
              banner == BannerType.rejectedBanner
                  ? Get.to(RetryCertifPage())
                  : null,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: banner.color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: banner.color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            cusFaIcon(banner.icon, color: banner.color, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                banner.text,
                style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle())
                    .copyWith(
                      color: banner.color,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  } else {
    return getChurchIssueBanner(context);
  }
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

  BannerType({required this.icon, required this.color, this.text = ""});

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

  BannerType copyWith({IconData? icon, Color? color, String? text}) {
    return BannerType(
      icon: icon ?? this.icon,
      color: color ?? this.color,
      text: text ?? this.text,
    );
  }
}
