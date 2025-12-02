import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

Future<void> showModal({
  required BuildContext context,
  required Widget dialog,
}) {
  return showDialog(
    context: context,
    anchorPoint: const Offset(200, 389),
    builder: (context) {
      return dialog;
    },
  );
}

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({
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
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(40),
                child: Container(
                  width: 500,
                  decoration: BoxDecoration(
                    color: notifire.getContainer,
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
                              color: notifire.getMainText,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              color: notifire.getMainText,
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
                            color: notifire.getMainText,
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
        ),
      ),
    );
  }
}

Future<void> showImageModal(BuildContext context, {required String imageUrl}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: FastCachedImageProvider(imageUrl),
              loadingBuilder:
                  (context, event) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: imageShimmerPlaceholder(height: 400)
                    ),
                  ),
              backgroundDecoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: cusFaIcon(FontAwesomeIcons.xmark, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
