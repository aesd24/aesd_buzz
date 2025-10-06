import 'package:aesd/components/certification_banner.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/provider/auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

BannerType? getBannerType(BuildContext context) {
  final user = Provider.of<Auth>(context, listen: false).user;
  if (user?.church == null) {
    return BannerType.waitingBanner.copyWith(
      text: "Vous n'avez pas encore d'église. Créez ou intégrez-en une",
      icon: FontAwesomeIcons.church,
    );
  }
  return null;
}

PreferredSize? getChurchIssueBanner(BuildContext context) {
  final banner = getBannerType(context);
  if (banner != null) {
    return PreferredSize(
      preferredSize: Size(double.infinity, 70),
      child: Expanded(
        child: GestureDetector(
          onTap: () {},
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
  return null;
}
