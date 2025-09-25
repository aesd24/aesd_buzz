import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/divider.dart';
import 'package:aesd/components/drawer.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/models/user_model.dart';
import 'package:aesd/pages/social/church/creation/main.dart';
import 'package:aesd/pages/social/church/detail.dart';
import 'package:aesd/pages/wallet/wallet.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/pages/dashboard/ceremony.dart';
import 'package:aesd/pages/dashboard/community.dart';
import 'package:aesd/pages/dashboard/events.dart';
import 'package:aesd/pages/dashboard/programs.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.user});

  final UserModel user;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoading = false;
  List<ChurchModel> userChurches = [];

  Future<void> init() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Church>(context, listen: false).getUserChurches().then((
        value,
      ) {
        userChurches = Provider.of<Church>(context, listen: false).userChurches;
        setState(() {});
      });
    } catch (e) {
      e.printError();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: customBackButton(),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: Row(
                children: [
                  Text(
                    widget.user.name,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(150),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    backgroundImage:
                        widget.user.photo != null
                            ? NetworkImage(widget.user.photo!)
                            : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                textDivider("Liste de vos églises"),
                Consumer<Church>(
                  builder: (context, churchProvider, child) {
                    if (churchProvider.churches.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: notFoundTile(
                          text: "Vous n'avez aucune église",
                          icon: Icons.church_outlined,
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          churchProvider.churches.length,
                          (index) {
                            return churchCard(
                              church: churchProvider.userChurches[index],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget churchCard({required ChurchModel church}) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha(100),
            blurRadius: 2,
            offset: Offset(0.5, 0.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton(
              icon: FaIcon(
                FontAwesomeIcons.ellipsisVertical,
                size: 16,
                color: Colors.black,
              ),
              onSelected: (value) {
                if (value == "profil") {
                  Get.to(ChurchDetailPage());
                } else if (value == "edit") {
                  Get.to(
                    MainChurchCreationPage(editMode: true, churchId: church.id),
                  );
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: "profil",
                      child: Text("Consulter le profil"),
                    ),
                    PopupMenuItem(
                      value: "edit",
                      child: Text("Modifier l' église"),
                    ),
                  ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (church.logo != null)
                  Container(
                    height: 80,
                    width: 80,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(church.logo!),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 5),
                Text(church.name),

                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 10),
                  child: Wrap(
                    runAlignment: WrapAlignment.center,
                    alignment: WrapAlignment.center,
                    spacing: 13,
                    runSpacing: 10,
                    children: [
                      customIconButton(
                        label: "Porte-feuille",
                        icon: FontAwesomeIcons.wallet,
                        color: Colors.green,
                        destination: Wallet(),
                      ),
                      customIconButton(
                        destination: ProgramListPage(),
                        color: Colors.purple,
                        icon: FontAwesomeIcons.calendarWeek,
                        label: "Programme",
                      ),
                      customIconButton(
                        destination: ChurchEvents(churchId: church.id),
                        color: Colors.amber,
                        icon: FontAwesomeIcons.solidCalendarDays,
                        label: "Evènements",
                      ),
                      customIconButton(
                        destination: CeremoniesManagement(churchId: church.id),
                        color: Colors.orange,
                        icon: FontAwesomeIcons.film,
                        label: "Cérémonies",
                      ),
                      customIconButton(
                        destination: DashboardCommunityPage(
                          churchId: church.id,
                        ),
                        color: Colors.blue,
                        icon: FontAwesomeIcons.peopleGroup,
                        label: "Communauté",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget customIconButton({
    required String label,
    required IconData icon,
    Color color = Colors.blue,
    Widget? destination,
  }) {
    return TextButton.icon(
      onPressed: destination != null ? () => Get.to(destination) : null,
      icon: FaIcon(icon, size: 18),
      label: Text(label),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(color.withAlpha(80)),
        iconColor: WidgetStatePropertyAll(color),
        foregroundColor: WidgetStatePropertyAll(color),
        overlayColor: WidgetStatePropertyAll(color.withAlpha(100)),
      ),
    );
  }

  Column customStat(
    BuildContext context, {
    required int value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }
}
