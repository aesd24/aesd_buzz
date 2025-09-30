import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/components/icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CeremonyModel {
  late int id;
  late String title;
  late String description;
  late String video;
  late DateTime date;
  late int churchId;

  CeremonyModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    title = json['title'];
    description = json['description'];
    video = json['media'];
    date = DateTime.parse(json['event_date']);
    churchId = json['id_eglise'];
  }

  Widget card(BuildContext context, {
    Future Function()? onDelete,
    bool dashboardAccess = false
  }) {
    return InkWell(
    overlayColor: WidgetStateProperty.all(Colors.orange.shade50),
    onTap: () => Get.toNamed(Routes.ceremonyDetail, arguments: {"ceremonyId": id}),
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(7)
              )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    cusFaIcon(FontAwesomeIcons.film, color: Colors.white),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.white
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${date.day}/${date.month}/${date.year}",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.white70
                  ),
                )
              ]
            ),
          ),
    
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey.shade700
                  )
                ),
                if (dashboardAccess) Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.amber.shade100),
                          iconColor: WidgetStateProperty.all(Colors.amber)
                        ),
                        icon: FaIcon(FontAwesomeIcons.pen, size: 20)
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
  }
}