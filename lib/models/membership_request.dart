import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/modal.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class MembershipRequestModel {
  bool isLoading = false;
  String state = 'pending';
  late int id;
  late String churchName;
  late int churchId;
  late String requesterName;
  late int requesterId;
  late String requesterEmail;
  late DateTime requestDate;

  MembershipRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    state = json['status'] ?? 'pending';
    churchName = json['church_name'];
    churchId = json['church_id'];
    requesterName = json['requester_name'];
    requesterId = json['requester_id'];
    requesterEmail = json['requester_email'];
    requestDate = DateTime.parse(json['created_at']);
  }

  Widget buildWidget(
    BuildContext context, {
    required Future Function(MembershipRequestModel) onValidate,
    required Future Function(MembershipRequestModel) onReject,
  }) {
    Color? mainColor;
    if (state == "accepted") {
      mainColor = Colors.green;
    } else if (state == "rejected") {
      mainColor = Colors.red;
    }
    Color shadowColor = mainColor ?? notifire.getMaingey;
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: mainColor ?? notifire.getContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withAlpha(75),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: _buildStateDisplay(
        context,
        onValidate: onValidate,
        onReject: onReject,
      ),
    );
  }

  Widget _buildStateDisplay(
    BuildContext context, {
    required Future Function(MembershipRequestModel) onValidate,
    required Future Function(MembershipRequestModel) onReject,
  }) {
    if (state != "pending") {
      bool accepted = state == "accepted";
      return Column(
        children: [
          FaIcon(
            accepted
                ? FontAwesomeIcons.solidCircleCheck
                : FontAwesomeIcons.solidCircleXmark,
            color: Colors.white,
            size: 40,
          ),
          SizedBox(height: 20),
          Text(
            accepted
                ? "Demande d'adhésion acceptée"
                : "Demande d'adhésion refusée",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.white),
          ),
        ],
      );
    }

    return Column(
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
                        MessageService.showInfoMessage("Bientôt disponible...");
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

        // Boutons
        isLoading
            ? Padding(
              padding: const EdgeInsets.only(top: 15),
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(10),
              ),
            )
            : Align(
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
    );
  }
}
