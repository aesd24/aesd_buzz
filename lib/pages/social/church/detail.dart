import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/modal.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/models/user_model.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/pages/ceremonies/short_list.dart';
import 'package:aesd/services/message.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import 'community.dart';
import 'day_program.dart';

class ChurchDetailPage extends StatefulWidget {
  const ChurchDetailPage({super.key});

  @override
  State<ChurchDetailPage> createState() => _ChurchDetailPageState();
}

class _ChurchDetailPageState extends State<ChurchDetailPage> {
  int? churchId;
  UserModel? owner;
  List<UserModel> members = [];
  bool _isLoading = false;

  bool displayName = false;

  // controllers
  final _scrollController = ScrollController();

  Future<void> onSubscribe(int churchId, bool subscribed) async {
    if (subscribed) {
      return showModal(
        context: context,
        dialog: CustomAlertDialog(
          title: "Désabonnement",
          content: "Vous allez vous désabonner. Voulez-vous continuer ?",
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.grey),
              ),
              child: Text("Annuler"),
            ),
            TextButton.icon(
              onPressed: () {
                Get.back();
                handleSubscribtion(churchId, !subscribed);
              },
              icon: FaIcon(FontAwesomeIcons.xmark),
              iconAlignment: IconAlignment.end,
              label: Text("Me désabonner"),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.red),
                iconColor: WidgetStatePropertyAll(Colors.red),
                overlayColor: WidgetStatePropertyAll(Colors.red.shade100),
              ),
            ),
          ],
        ),
      );
    } else {
      if (Provider.of<Auth>(context, listen: false).user!.churchId != null) {
        showModal(
          context: context,
          dialog: CustomAlertDialog(
            title: "Changer d'église",
            content:
                "Vous serez désabonner à votre église actuelle."
                "Voulez-vous vraiment continuer ?",
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.grey),
                ),
                child: Text("Annuler"),
              ),
              TextButton.icon(
                onPressed: () {
                  Get.back();
                  handleSubscribtion(churchId, !subscribed);
                },
                icon: FaIcon(FontAwesomeIcons.arrowsRotate),
                iconAlignment: IconAlignment.end,
                label: Text("Changer"),
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.orange),
                  iconColor: WidgetStatePropertyAll(Colors.orange),
                  overlayColor: WidgetStatePropertyAll(Colors.orange.shade100),
                ),
              ),
            ],
          ),
        );
      } else {
        handleSubscribtion(churchId, !subscribed);
      }
    }
  }

  Future<void> handleSubscribtion(int churchId, bool willSubscribe) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Church>(
        context,
        listen: false,
      ).subscribe(churchId, willSubscribe: willSubscribe).then((value) async {
        MessageService.showSuccessMessage(value);
        await Provider.of<Auth>(context, listen: false).getUserData();
      });
    } on HttpException {
      MessageService.showErrorMessage("L'opération a échoué !");
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu est survenue");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getChurch(int churchId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Church>(context, listen: false)
          .fetchChurch(churchId)
          .then(
            (value) => {
              setState(() {
                //church = ChurchModel.fromJson(value['eglise']);
                members.clear();
                for (var member in value['members']) {
                  members.add(UserModel.fromJson(member));
                }
                owner = UserModel.fromJson(value['user']);
              }),
            },
          );
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendu est survenue !");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // init scroll controller
    _scrollController.addListener(() {
      displayName = _scrollController.offset.toInt() > 50;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      churchId = Get.arguments['churchId'];
      await getChurch(churchId!);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<Auth>(context).user!;
    bool subscribed = churchId == user.churchId;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: _isLoading ? Padding(
          padding: const EdgeInsets.all(20),
          child: ListShimmerPlaceholder(),
        ) : Consumer<Church>(
          builder: (context, provider, child) {
            final church = provider.selectedChurch;
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: size.height * .4,
                  backgroundColor: notifire.getbgcolor,
                  leading: customBackButton(),
                  flexibleSpace: FlexibleSpaceBar(
                    title: displayName ? Text(
                      church?.name ?? "",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: notifire.getMainText,
                      ),
                    ) : null,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        image:
                            church?.image == null
                                ? null
                                : DecorationImage(
                                  image: FastCachedImageProvider(church!.image),
                                  fit: BoxFit.cover,
                                ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              notifire.getContainer.withAlpha(10),
                              notifire.getContainer.withAlpha(80),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                church?.name ?? "",
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.userTie,
                                    size: 16,
                                  ),
                                  SizedBox(width: 7),
                                  Text(
                                    owner?.name ?? "Inconnu",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall!.copyWith(
                                      color: Colors.white.withAlpha(170),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // title: Text(
                    //   church?.name ?? "Chargement...",
                    //   style: textTheme.titleMedium,
                    // ),
                  ),
                ),
                SliverAppBar(
                  pinned: true,
                  leading: SizedBox(),
                  leadingWidth: 0,
                  toolbarHeight: 10,
                  expandedHeight: size.height * .23,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: TextButton.icon(
                                onPressed:
                                    () => onSubscribe(churchId!, subscribed),
                                icon: FaIcon(
                                  subscribed
                                      ? FontAwesomeIcons.bookmark
                                      : FontAwesomeIcons.solidBookmark,
                                ),
                                iconAlignment: IconAlignment.end,
                                label: Text(
                                  subscribed ? "Se désabonner" : "S'abonner",
                                ),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    subscribed ? Colors.transparent : Colors.blue,
                                  ),
                                  overlayColor: WidgetStateProperty.all(
                                    subscribed
                                        ? Colors.red.withAlpha(110)
                                        : Colors.white.withAlpha(110),
                                  ),
                                  iconColor: WidgetStateProperty.all(
                                    subscribed ? Colors.red : Colors.white,
                                  ),
                                  foregroundColor: WidgetStateProperty.all(
                                    subscribed ? Colors.red : Colors.white,
                                  ),
                                  shape:
                                      subscribed
                                          ? WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              side: const BorderSide(
                                                width: 2,
                                                color: Colors.red,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                100,
                                              ),
                                            ),
                                          )
                                          : null,
                                ),
                              ),
                            ),
                          ),

                          customDataTile(
                            icon: FontAwesomeIcons.locationDot,
                            text: church!.address,
                          ),
                          customDataTile(
                            icon: FontAwesomeIcons.phone,
                            text: church.phone,
                          ),
                          customDataTile(
                            icon: FontAwesomeIcons.solidEnvelope,
                            text: church.email,
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    tabs: [
                      Tab(text: "Programme"),
                      Tab(text: "Céremonies"),
                      Tab(text: "Membres"),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: TabBarView(
                      children: [
                        Program(churchId: churchId!),
                        CeremonyShortList(churchId: churchId!),
                        Community(members: members, subscribed: subscribed),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget customDataTile({required IconData? icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(icon, size: 15, color: Colors.red),
          const SizedBox(width: 5),
          Flexible(
            child: Text(text, style: Theme.of(context).textTheme.labelMedium!),
          ),
        ],
      ),
    );
  }

  InkWell customNavitem(
    BuildContext context, {
    required int index,
    required String label,
    required int currentIndex,
  }) {
    return InkWell(
      child: AnimatedContainer(
        padding: const EdgeInsets.all(7),
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border:
              index == currentIndex
                  ? const Border(
                    bottom: BorderSide(width: 5, color: Colors.green),
                  )
                  : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: index == currentIndex ? Colors.green : null,
          ),
        ),
      ),
    );
  }
}
