import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatefulWidget {
  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed
  });

  final String text;
  final Widget icon;
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
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))
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
