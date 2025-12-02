import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/bottom_sheets.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/certification_banner.dart';
import 'package:aesd/components/divider.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/models/user_model.dart';
import 'package:aesd/pages/dashboard/programs/list.dart';
import 'package:aesd/pages/social/church/creation/annexe.dart';
import 'package:aesd/pages/social/church/creation/main.dart';
import 'package:aesd/pages/social/church/detail.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/pages/dashboard/ceremony.dart';
import 'package:aesd/pages/dashboard/community/main.dart';
import 'package:aesd/pages/dashboard/events.dart';
import 'package:aesd/services/message.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
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

  Future<void> init() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Church>(context, listen: false).getUserChurches();
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            getCertificationBanner(context) ?? const SizedBox(),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textDivider("Liste de vos églises"),
                  CustomTextButton(
                    onPressed: () {
                      if (widget.user.certifStatus !=
                          CertificationStates.approved) {
                        return MessageService.showWarningMessage(
                          "Votre compte n'est pas validé vous n'avez pas les accès requis !",
                        );
                      }

                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder:
                            (context) => Container(
                              height: MediaQuery.of(context).size.height * .45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                color: notifire.getbgcolor,
                              ),
                              child: Scaffold(
                                backgroundColor: Colors.transparent,
                                appBar: AppBar(
                                  leading: customBackButton(
                                    icon: FontAwesomeIcons.xmark,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                ),
                                body: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      CustomBottomSheetButtom(
                                        onPressed:
                                            () => Get.to(
                                              () => MainChurchCreationPage(),
                                            ),
                                        text: "Eglise principale",
                                        image: Image.asset(
                                          "assets/icons/crown.png",
                                          height: 100,
                                          width: 100,
                                        ),
                                      ),
                                      CustomBottomSheetButtom(
                                        onPressed:
                                            () => Get.to(
                                              () => AnnexeChurchForm(),
                                            ),
                                        text: "Eglise secondaire",
                                        image: Image.asset(
                                          "assets/icons/second.png",
                                          height: 100,
                                          width: 100,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      );
                    },
                    label: "Créer une église",
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<Church>(
                builder: (context, churchProvider, child) {
                  if (churchProvider.userChurches.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: notFoundTile(
                        text: "Vous n'avez aucune église",
                        icon: Icons.church_outlined,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: churchProvider.userChurches.length,
                    itemBuilder: (context, index) {
                      final church = churchProvider.userChurches[index];
                      return churchCard(church: church);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget churchCard({required ChurchModel church}) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
      margin: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
      decoration: BoxDecoration(
        color: notifire.getContainer,
        boxShadow: [
          BoxShadow(
            color: notifire.getMaingey.withAlpha(75),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: FastCachedImageProvider(
                church.logo ?? church.image,
              ),
              backgroundColor: notifire.getMaingey.withAlpha(200),
            ),
            title: Text(church.name),
            trailing: PopupMenuButton(
              onSelected: (value) {
                if (value == "profil") {
                  Get.to(
                    () => ChurchDetailPage(),
                    arguments: {"churchId": church.id},
                  );
                } else if (value == "update") {
                  Get.to(
                    () => MainChurchCreationPage(
                      editMode: true,
                      churchId: church.id,
                    ),
                  );
                } else if (value == "delete") {
                  MessageService.showInfoMessage("Bientôt disponible...");
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: "profil",
                    child: Text("Consulter le profil"),
                  ),
                  PopupMenuItem(
                    value: "update",
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Modifier l'église"),
                        SizedBox(width: 10),
                        cusFaIcon(
                          FontAwesomeIcons.pen,
                          color: notifire.warning,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "delete",
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Fermer l'église"),
                        SizedBox(width: 10),
                        cusFaIcon(
                          FontAwesomeIcons.xmark,
                          color: notifire.danger,
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),

          if (church.validationState != 'approved')
            church.buildValidationChurchBanner(context),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            child: Divider(
              thickness: 2,
              radius: BorderRadius.circular(10),
              color: notifire.getMaingey,
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              /*customIconButton(
                label: "Porte-feuille",
                icon: FontAwesomeIcons.wallet,
                color: Colors.green,
                destination: Wallet(),
              ),*/
              customIconButton(
                destination: ProgramListPage(),
                arg: {"churchId": church.id},
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
                color: Colors.red,
                icon: FontAwesomeIcons.film,
                label: "Cérémonies",
              ),
              customIconButton(
                destination: DashboardCommunityPage(),
                arg: {"churchId": church.id},
                color: Colors.blue,
                icon: FontAwesomeIcons.peopleGroup,
                label: "Communauté",
              ),
            ],
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
    dynamic arg,
  }) {
    return TextButton.icon(
      onPressed:
          destination != null
              ? () => Get.to(() => destination, arguments: arg)
              : null,
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
