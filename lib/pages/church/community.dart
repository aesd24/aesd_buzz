import 'package:aesd/pages/chats/message_on.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';

class Community extends StatefulWidget {
  const Community({super.key, required this.members, this.subscribed = false, });

  final List<UserModel> members;
  final bool subscribed;

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Serviteurs de l'église",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Column(
            children: List.generate(widget.members.length, (index) {
              var current = widget.members[index];
              return Card(
                  child: current.buildTile()
              );
            }),
          ),

          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text(
              "Groupes de discution",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Column(
              children: List.generate(3, (index) => Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    onTap: () => Get.to(MessageOnPage()),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey.shade100,
                      child: FaIcon(
                        FontAwesomeIcons.userGroup,
                        size: 18,
                        color: Colors.blueGrey,
                      ),
                    ),
                    title: Text(
                        "Nom du groupe de chat",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!.copyWith(
                          color: Colors.blueGrey.shade700,
                        )
                    ),
                  )
              ))
          )
        ],
      ),
    );
  }
}