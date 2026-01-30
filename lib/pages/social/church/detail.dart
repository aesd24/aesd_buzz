import 'dart:io';
import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/modal.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/pages/ceremonies/short_list.dart';
import 'package:aesd/services/message.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
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
  bool _isLoading = false;
  bool _subscribing = false;

  bool displayName = false;

  // controllers
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0,
  );

  Future<void> onSubscribe(
    int churchId,
    bool subscribed,
    String accountType,
  ) async {
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
                handleSubscribtion(churchId, !subscribed, accountType);
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
      if (Provider.of<Auth>(context, listen: false).user!.church?.id != null) {
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
                  handleSubscribtion(churchId, !subscribed, accountType);
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
        handleSubscribtion(churchId, !subscribed, accountType);
      }
    }
  }

  Future<void> handleSubscribtion(
    int churchId,
    bool willSubscribe,
    String accountType,
  ) async {
    try {
      setState(() {
        _subscribing = true;
      });
      if (accountType == Dictionnary.servant.code) {
        await Provider.of<Church>(
          context,
          listen: false,
        ).membershipRequest(churchId).then((value) async {
          MessageService.showSuccessMessage(value);
          if (mounted) {
            await Provider.of<Auth>(context, listen: false).getUserData();
          }
        });
      } else {
        await Provider.of<Church>(
          context,
          listen: false,
        ).subscribe(churchId, willSubscribe: willSubscribe).then((value) async {
          MessageService.showSuccessMessage(value);
          if (mounted) {
            await Provider.of<Auth>(context, listen: false).getUserData();
          }
        });
      }
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu est survenue");
    } finally {
      setState(() {
        _subscribing = false;
      });
    }
  }

  Future<void> getChurch(int churchId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Church>(context, listen: false).fetchChurch(churchId);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 100) {
        setState(() {
          displayName = true;
        });
      } else {
        setState(() {
          displayName = false;
        });
      }
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
    bool subscribed = churchId == user.church?.id;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body:
            _isLoading
                ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListShimmerPlaceholder(),
                  ),
                )
                : Consumer<Church>(
                  builder: (context, provider, child) {
                    final church = provider.selectedChurch;

                    if (church == null) {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: notFoundTile(
                          icon: Icons.church_outlined,
                          text: "Impossible d'obtenir l'église",
                        ),
                      );
                    }
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          expandedHeight: size.height * .4,
                          backgroundColor: notifire.getbgcolor,
                          leading: customBackButton(),
                          actions:
                              (subscribed &&
                                      user.accountType.code ==
                                          Dictionnary.servant.code)
                                  ? null
                                  : [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child:
                                          _subscribing
                                              ? CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                              )
                                              : CustomTextButton(
                                                onPressed:
                                                    () => handleSubscribtion(
                                                      church.id,
                                                      !subscribed,
                                                      user.accountType.code,
                                                    ),
                                                label:
                                                    !subscribed
                                                        ? "S'abonner"
                                                        : "Me désabonner",
                                                type: ButtonType(
                                                  icon: cusFaIcon(
                                                    !subscribed
                                                        ? FontAwesomeIcons
                                                            .solidBookmark
                                                        : FontAwesomeIcons
                                                            .bookmark,
                                                    color: Colors.white,
                                                  ),
                                                  foreColor: Colors.white,
                                                  backColor:
                                                      !subscribed
                                                          ? notifire.info
                                                          : notifire.danger,
                                                  iconColor: Colors.white,
                                                ),
                                              ),
                                    ),
                                  ],
                          flexibleSpace: FlexibleSpaceBar(
                            title:
                                displayName
                                    ? Text(
                                      church.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium!.copyWith(
                                        color: notifire.getMainText,
                                      ),
                                    )
                                    : null,
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                image: DecorationImage(
                                  image: FastCachedImageProvider(
                                    church.logo ?? '',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      notifire.getContainer.withAlpha(170),
                                      notifire.getOnContainer.withAlpha(60),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(25),
                                    child: Text(
                                      church.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge!.copyWith(
                                        color: notifire.getContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  runAlignment: WrapAlignment.start,
                                  spacing: 15,
                                  runSpacing: 10,
                                  children: [
                                    customDataTile(
                                      icon: cusFaIcon(FontAwesomeIcons.userTie),
                                      text:
                                          church.owner?.user?.name ?? "Inconnu",
                                    ),
                                    customDataTile(
                                      icon: cusFaIcon(
                                        FontAwesomeIcons.locationDot,
                                      ),
                                      text: church.address,
                                    ),
                                    customDataTile(
                                      icon: cusFaIcon(FontAwesomeIcons.phone),
                                      text: church.phone,
                                    ),
                                    customDataTile(
                                      icon: cusFaIcon(FontAwesomeIcons.at),
                                      text: church.email,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 25),
                                  child: TabBar(
                                    isScrollable: true,
                                    tabAlignment: TabAlignment.start,
                                    dividerColor: Colors.transparent,
                                    dividerHeight: 0,
                                    tabs: [
                                      Tab(
                                        icon: cusFaIcon(
                                          FontAwesomeIcons.calendar,
                                        ),
                                        child: Text("Programme"),
                                      ),
                                      Tab(
                                        icon: cusFaIcon(FontAwesomeIcons.film),
                                        child: Text("Cérémonies"),
                                      ),
                                      Tab(
                                        icon: cusFaIcon(FontAwesomeIcons.users),
                                        child: Text("Communauté"),
                                      ),
                                      Tab(
                                        icon: cusFaIcon(FontAwesomeIcons.church),
                                        child: Text("Annexe"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverFillRemaining(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: TabBarView(
                              children: [
                                Program(churchId: church.id),
                                CeremonyShortList(churchId: church.id),
                                Community(),
                                _buildAnnexeTab(church),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      ),
    );
  }

  Widget customDataTile({required Widget icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 7),
          Flexible(
            child: Text(text, style: Theme.of(context).textTheme.labelLarge!),
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

  Widget _buildAnnexeTab(dynamic church) {
    if (church.annexes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.church,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Aucune annexe disponible',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: church.annexes.length,
      itemBuilder: (context, index) {
        final annexe = church.annexes[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              print("Navigating to annexe ID: ${annexe.id}");
              Get.to(
                () => ChurchDetailPage(),
                arguments: {'churchId': annexe.id},
                preventDuplicates: false, // Important pour pouvoir empiler les pages de detail
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                // On retire le color ici car il est pris par le Material/InkWell context
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: notifire.getMaingey.withAlpha(50),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Church image
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    child: FastCachedImage(
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      url: annexe.logo ?? "",
                      loadingBuilder: (context, progress) {
                        return imageShimmerPlaceholder(height: 180);
                      },
                    ),
                  ),
                  
                  // Church info
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Church name
                        Text(
                          annexe.name,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        SizedBox(height: 12),
                        
                        // Address
                        if (annexe.address.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.mapPin,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  annexe.address,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        
                        SizedBox(height: 8),
                        
                        // Phone
                        if (annexe.phone.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.phone,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 8),
                              Text(
                                '(+225) ${annexe.phone}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


}
