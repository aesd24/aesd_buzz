import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/pages/dashboard/community/membership_requests.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../provider/church.dart';

class DashboardCommunityPage extends StatefulWidget {
  const DashboardCommunityPage({super.key});

  @override
  State<DashboardCommunityPage> createState() => _DashboardCommunityPageState();
}

class _DashboardCommunityPageState extends State<DashboardCommunityPage> {
  bool _isLoading = false;

  void getChurch(int churchId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Church>(context, listen: false).fetchChurch(churchId);
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendue est survenue !");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final churchId = Get.arguments['churchId'] as int?;
      if (churchId != null) getChurch(churchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: FaIcon(FontAwesomeIcons.xmark, size: 20),
        ),
        title: Text("Communauté"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          CustomTextButton(
                            onPressed:
                                () => showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  builder:
                                      (context) => MembershipRequestsList(),
                                ),
                            label: "Demandes d'adhésion",
                          ),

                          /*Positioned(
                            right: 5,
                            top: 0,
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor: Colors.red,
                            ),
                          )*/
                        ],
                      ),
                    ),

                    CustomTextButton(
                      onPressed:
                          () => MessageService.showInfoMessage(
                            "Bientôt disponible...",
                          ),
                      label: "Rechercher un fidèle",
                    ),
                  ],
                ),
              ),
              Consumer<Church>(
                builder: (context, provider, child) {
                  final members = provider.selectedChurch!.members;

                  if (members.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Center(
                        child: notFoundTile(
                          text: "Aucun serviteur trouvé",
                          icon: FontAwesomeIcons.userTie,
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: List.generate(members.length, (index) {
                        final member = members[index];
                        return member.buildWidget(context);
                      }),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
