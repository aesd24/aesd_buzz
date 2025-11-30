import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/models/user_model.dart';
import 'package:aesd/services/message.dart';
import 'package:get/get.dart';

void openUserChurch(UserModel user) {
  if (user.church != null) {
    Get.toNamed(
      Routes.churchDetail,
      arguments: {'churchId': user.church!.id},
    );
  } else {
    MessageService.showInfoMessage(
      "Aucune église associé à ce compte",
    );
  }
}