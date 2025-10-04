import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ButtonType {
  final Widget? icon;
  final Color foreColor;
  final Color backColor;
  final Color iconColor;

  const ButtonType({
    required this.icon,
    required this.foreColor,
    required this.backColor,
    required this.iconColor,
  });

  static final ButtonType success = ButtonType(
    icon: cusFaIcon(FontAwesomeIcons.check, color: Colors.white),
    foreColor: Colors.white,
    backColor: notifire.success,
    iconColor: Colors.white,
  );

  static final ButtonType warning = ButtonType(
    icon: cusFaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.white),
    foreColor: Colors.white,
    backColor: notifire.warning,
    iconColor: Colors.white,
  );

  static final ButtonType error = ButtonType(
    icon: cusFaIcon(FontAwesomeIcons.circleXmark, color: Colors.white),
    foreColor: Colors.white,
    backColor: notifire.danger,
    iconColor: Colors.white,
  );

  static final ButtonType info = ButtonType(
    foreColor: Colors.white,
    backColor: notifire.info,
    iconColor: Colors.white,
    icon: null,
  );

  ButtonType get disabled => ButtonType(
    foreColor: Colors.white,
    backColor: notifire.getMaingey,
    iconColor: Colors.white,
    icon: null,
  );
}

// elevated button
class CustomElevatedButton extends StatefulWidget {
  const CustomElevatedButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
  });

  final String text;
  final Widget? icon;
  final void Function()? onPressed;

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: widget.onPressed,
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          backgroundColor: WidgetStatePropertyAll(appMainColor),
          overlayColor: WidgetStatePropertyAll(Colors.white38),
          elevation: WidgetStatePropertyAll(0),
          fixedSize: WidgetStatePropertyAll(Size.fromHeight(60)),
        ),
        label: Text(
          widget.text,
          style: mediumBlackTextStyle.copyWith(color: Colors.white),
        ),
        icon: widget.icon,
        iconAlignment: IconAlignment.end,
      ),
    );
  }
}

// text button
class CustomTextButton extends StatefulWidget {
  const CustomTextButton({
    super.key,
    this.onPressed,
    required this.label,
    this.icon,
    this.type,
    this.disabled = false,
  });

  final void Function()? onPressed;
  final String label;
  final Widget? icon;
  final ButtonType? type;
  final bool disabled;

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
  @override
  Widget build(BuildContext context) {
    ButtonType type = widget.type ?? ButtonType.info;
    if (widget.disabled) {
      type = type.disabled;
    }
    return TextButton.icon(
      icon: widget.icon ?? type.icon,
      iconAlignment: IconAlignment.end,
      onPressed: !widget.disabled ? widget.onPressed : null,
      label: Text(widget.label),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(type.backColor),
        iconColor: WidgetStatePropertyAll(type.iconColor),
        foregroundColor: WidgetStatePropertyAll(type.foreColor),
        fixedSize: WidgetStatePropertyAll(Size.fromHeight(34)),
        overlayColor: WidgetStatePropertyAll(
          widget.disabled ? Colors.transparent : Colors.white38,
        ),
        elevation: WidgetStatePropertyAll(0),
      ),
    );
  }
}

Widget customActionButton(
  Widget icon,
  String text, {
  void Function()? onPressed,
}) {
  return InkWell(
    overlayColor: WidgetStatePropertyAll(notifire.getMaingey.withAlpha(70)),
    borderRadius: BorderRadius.circular(100),
    radius: 20,
    onTap: onPressed,
    child: Padding(
      padding: const EdgeInsets.all(7),
      child: Row(children: [icon, SizedBox(width: 5), Text(text)]),
    ),
  );
}

Widget customBackButton({IconData? icon = FontAwesomeIcons.arrowLeftLong, Color? color}) {
  return IconButton(
    onPressed: () => Get.back(),
    icon: cusFaIcon(icon!, color: color),
  );
}
