import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

Future<void> showModal({
  required BuildContext context,
  required CustomDialog dialog,
}) {
  return showDialog(
    context: context,
    anchorPoint: const Offset(200, 389),
    builder: (context) {
      return dialog;
    },
  );
}

class CustomDialog extends StatefulWidget {
  const CustomDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    required this.content,
    this.svgIllustration,
    this.onOk,
  });

  final String title;
  final String? subtitle;
  final String content;
  final List<Widget>? actions;
  final String? svgIllustration;
  final void Function()? onOk;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(40),
            child: Container(
              width: 500,
              decoration: BoxDecoration(
                color: notifire!.getcontiner,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: notifire!.getMainText,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                          color: notifire!.getMainText,
                          fontSize: 15,
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 210,
                        width: 210,
                        child: SvgPicture.asset(
                          widget.svgIllustration ??
                              "assets/illustrations/notification.svg",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      widget.content,
                      style: mediumBlackTextStyle.copyWith(
                        height: 1.7,
                        color: notifire!.getMainText,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        children: [
                          if (widget.actions != null) ...?widget.actions,

                          if (widget.actions == null)
                            CustomTextButton(
                              label: "D'accord !",
                              onPressed:
                                  () =>
                                      widget.onOk != null
                                          ? widget.onOk!()
                                          : Get.back(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
