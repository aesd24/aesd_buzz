import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/provider/church.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Church>(
      builder: (context, provider, child) {
        final members = provider.selectedChurch!.members;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Serviteurs de l'église",
                style: Theme.of(
                  context,
                ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              if (members.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: notFoundTile(
                    icon: FontAwesomeIcons.users,
                    text: "Aucun membre trouvé pour cette église",
                  ),
                ),
              if (members.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: List.generate(members.length, (index) {
                      final current = members[index];
                      return Container(
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: notifire.getContainer,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(
                            color: notifire.getMaingey.withAlpha(70),
                            blurRadius: 10,
                            spreadRadius: 2
                          )]
                        ),
                        child: current.buildTile()
                      );
                    }),
                  ),
                ),

              /*Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text(
                  "Groupes de discution",
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                children: List.generate(
                  3,
                  (index) => Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      onTap: () => Get.to(() =>MessageOnPage()),
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
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),*/
            ],
          ),
        );
      }
    );
  }
}
