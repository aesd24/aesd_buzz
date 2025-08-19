import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'icon.dart';


IconButton customAppBarLeading() {
  return IconButton(
    onPressed: () => Get.back(),
    icon: cusFaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white),
  );
}

Padding loadingBar() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: SizedBox(height: 1.5, child: LinearProgressIndicator()),
  );
}
