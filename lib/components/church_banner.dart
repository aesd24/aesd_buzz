import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/components/certification_banner.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/pages/dashboard/dashboard.dart';
import 'package:aesd/pages/social/church/creation/main.dart';
import 'package:aesd/pages/social/social.dart';
import 'package:aesd/provider/auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

BannerType? getChurchBannerType(BuildContext context) {
  final user = Provider.of<Auth>(context, listen: false).user;
  if (user != null && user.accountType.code == Dictionnary.servant.code) {
    // Si l'utilisateur n'a pas d'église
    if (user.church == null) {
      return BannerType.waitingBanner.copyWith(
        text: "Vous n'avez pas encore d'église. Créez ou intégrez-en une",
        icon: FontAwesomeIcons.church,
      );
    } 
    
    // Si l'église est en attente
    if (user.church!.validationState == "pending") {
      return BannerType.waitingBanner.copyWith(
        text: "La validation de votre église est en cours...",
        icon: FontAwesomeIcons.church,
      );
    } 
    
    // Si l'église est refusée
    if (user.church!.validationState == "rejected") {
      return BannerType.rejectedBanner.copyWith(
        text: "La validation de votre église a été refusée. Cliquez pour corriger.",
        icon: FontAwesomeIcons.church,
      );
    }
    
    // Si l'église est validée (approved), on ne retourne rien (pas de bannière)
  }
  return null;
}

Widget? getChurchIssueBanner(BuildContext context) {
  final provider = Provider.of<Auth>(context, listen: false);
  final user = provider.user;
  final banner = getChurchBannerType(context);

  if (banner != null && user != null) {
    // Cas spécial : pas d'église (avec liens cliquables)
    if (user.church == null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: banner.color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(10),
          color: banner.color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            cusFaIcon(banner.icon, color: banner.color, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle())
                      .copyWith(
                        color: banner.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                  children: [
                    const TextSpan(text: "Vous n'avez pas encore d'église. "),
                    TextSpan(
                      text: "Créez",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(() => MainChurchCreationPage());
                        },
                    ),
                    const TextSpan(text: " ou "),
                    TextSpan(
                      text: "intégrez-en une",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Revenir à la page principale (MainPage)
                          Get.until((route) => route.isFirst);
                          // Demander à SocialPage de naviguer vers l'onglet "Eglises" (index 2)
                          Future.delayed(const Duration(milliseconds: 350), () {
                            SocialPage.navigateToTab.value = 2;
                          });
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Autres cas : bannière cliquable normale
    return GestureDetector(
      onTap: () => Get.to(() => Dashboard(user: user)),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: banner.color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(10),
          color: banner.color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            cusFaIcon(banner.icon, color: banner.color, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                banner.text,
                style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle())
                    .copyWith(
                      color: banner.color,
                      fontWeight: FontWeight.w600,
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
