import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: notifire.getMainColor,
          backgroundImage:
              photoUrl != null ? FastCachedImageProvider(photoUrl!) : null,
          child:
              photoUrl != null
                  ? null
                  : cusFaIcon(
                    FontAwesomeIcons.solidUser,
                    color: notifire.getbgcolor,
                  ),
        ),
        SizedBox(width: 10),
        Text(name),
      ],
    );
  }
}

Widget customTransactionTile(
  BuildContext context, {
  required String label,
  required int amount,
  required DateTime date,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      border: Border.all(color: notifire.getmaintext),
      borderRadius: BorderRadius.circular(15),
    ),
    child: ListTile(
      leading: cusFaIcon(FontAwesomeIcons.rightLeft),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium!.copyWith(color: notifire.getTextColor1),
      ),
      subtitle: Row(
        children: [
          Text(
            formatDate(date),
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: notifire.getMainText.withAlpha(150),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CircleAvatar(
              radius: 3,
              backgroundColor: notifire.getMainText,
            ),
          ),
          Text(
            formatPrice(amount),
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(color: notifire.danger),
          ),
        ],
      ),
    ),
  );
}

Widget infoTile(BuildContext context,{required String text, required IconData icon}) {
  final textTheme = Theme.of(context).textTheme;
  final scheme = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(
      children: [
        cusFaIcon(FontAwesomeIcons.locationDot),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: textTheme.bodySmall!.copyWith(
              color: scheme.onSurface.withAlpha(100),
            ),
          ),
        ),
      ],
    ),
  );
}

Row textIconTile(BuildContext context, IconData icon, String text) {
  return Row(
    children: [
      cusFaIcon(icon, size: 14),
      SizedBox(width: 5),
      Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(color: notifire.getMainText),
      ),
    ],
  );
}