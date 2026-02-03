import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/components/certification_banner.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/provider/auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

BannerType? getBannerType(BuildContext context) {
  final user = Provider.of<Auth>(context, listen: false).user;
  if (user != null && user.accountType == Dictionnary.servant) {
    if (user.church == null) {
      return BannerType.waitingBanner.copyWith(
        text: "Vous n'avez pas encore d'église. Créez ou intégrez-en une",
        icon: FontAwesomeIcons.church,
      );
    }
  }
  return null;
}

Widget? getChurchIssueBanner(BuildContext context) {
  final banner = getBannerType(context);
  if (banner != null) {
    return GestureDetector(
      onTap: () {},
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
  }
  return null;
}
