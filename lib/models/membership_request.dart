import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/modal.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MembershipRequestModel {
  bool isLoading = false;
  String state = 'pending';
  late int id;
  late String churchName;
  late int churchId;
  late String requesterName;
  late String requesterEmail;
  late DateTime requestDate;

  MembershipRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    churchName = json['church_name'];
    churchId = json['church_id'];
    requesterName = json['requester_name'];
    requesterEmail = json['requester_email'];
    requestDate = DateTime.parse(json['created_at']);
  }

  Widget buildWidget(
    BuildContext context, {
    required Future Function(MembershipRequestModel) onValidate,
    required Future Function(MembershipRequestModel) onReject,
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: notifire.getContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: notifire.getMaingey.withAlpha(75),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "DMD-00$id",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: requesterName,
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          MessageService.showInfoMessage(
                            "Bientôt disponible...",
                          );
                        },
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(color: notifire.getMainColor),
                ),
                TextSpan(
                  text: " demande à devenir un serviteur de l'église ",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: notifire.getMainText),
                ),
                TextSpan(
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          Get.toNamed(
                            Routes.churchDetail,
                            arguments: {"churchId": churchId},
                          );
                        },
                  text: churchName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(color: notifire.getMainColor),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(top: 25),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextButton(
                    label: "Refuser",
                    type: ButtonType.error,
                    onPressed: () {
                      showModal(
                        context: context,
                        dialog: CustomAlertDialog(
                          title: "Refuser la demande d'adhésion",
                          content:
                              "Êtes vous sûr de vouloir refuser la demande d'adhésion ?",
                          actions: [
                            CustomTextButton(
                              label: "Refuser",
                              type: ButtonType.error,
                              onPressed: () {
                                Get.back();
                                onReject(this);
                              },
                            ),
                            CustomTextButton(
                              label: "Annuler",
                              type: ButtonType.info.copyWith(
                                backColor: Colors.blueGrey,
                              ),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 10),
                  CustomTextButton(
                    label: "Accepter",
                    type: ButtonType.success,
                    onPressed: () {
                      showModal(
                        context: context,
                        dialog: CustomAlertDialog(
                          title: "Accepter la demande d'adhésion",
                          content:
                              "Êtes vous sûr de vouloir accepter la demande d'adhésion ?",
                          actions: [
                            CustomTextButton(
                              label: "Valider",
                              type: ButtonType.success,
                              onPressed: () {
                                Get.back();
                                onValidate(this);
                              },
                            ),
                            CustomTextButton(
                              label: "Annuler",
                              type: ButtonType.info.copyWith(
                                backColor: Colors.blueGrey,
                              ),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ],
                        ),
                      );
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
}
