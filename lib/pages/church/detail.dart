import 'dart:io';
import 'package:aesd/components/dialog.dart';
import 'package:aesd/components/snack_bar.dart';
import 'package:aesd/services/navigation.dart';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/models/user_model.dart';
import 'package:aesd/providers/church.dart';
import 'package:aesd/providers/user.dart';
import 'package:aesd/screens/ceremonies/short_list.dart';
import 'package:aesd/screens/church/day_program.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'community.dart';

class ChurchDetailPage extends StatefulWidget {
  ChurchDetailPage({super.key, required this.churchId});

  int churchId;

  @override
  State<ChurchDetailPage> createState() => _ChurchDetailPageState();
}

class _ChurchDetailPageState extends State<ChurchDetailPage> {
  final _scrollController = ScrollController();
  int alpha = 0;
  setAlpha(int value) {
    setState(() {
      alpha = value;
    });
  }

  ChurchModel? church;
  UserModel? owner;
  List<UserModel> members = [];
  bool _isLoading = false;

  final _pageController = PageController(initialPage: 0);

  onSubscribe(subscribed) async {
    if (subscribed) {
      messageBox(
        context,
        title: "Désabonnement",
        content: Text("Vous allez vous désabonner. Voulez-vous continuer ?"),
        actions: [
          TextButton(
            onPressed: () => NavigationService.close(),
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(Colors.grey),
            ),
            child: Text("Annuler"),
          ),
          TextButton.icon(
            onPressed: () {
              NavigationService.close();
              handleSubscribtion(!subscribed);
            },
            icon: FaIcon(FontAwesomeIcons.xmark),
            iconAlignment: IconAlignment.end,
            label: Text("Me désabonner"),
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(Colors.red),
              iconColor: WidgetStatePropertyAll(Colors.red),
              overlayColor: WidgetStatePropertyAll(Colors.red.shade100),
            ),
          )
        ]
      );
      return;
    } else {
      if (Provider.of<User>(context, listen: false).user!.churchId != null){
        messageBox(
          context,
          title: "Changer d'église",
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Vous serez désabonner à votre église actuelle."),
              Text("Voulez-vous vraiment continuer ?"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => NavigationService.close(),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.grey),
              ),
              child: Text("Annuler"),
            ),
            TextButton.icon(
              onPressed: () {
                NavigationService.close();
                handleSubscribtion(!subscribed);
              },
              icon: FaIcon(FontAwesomeIcons.arrowsRotate),
              iconAlignment: IconAlignment.end,
              label: Text("Changer"),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.orange),
                iconColor: WidgetStatePropertyAll(Colors.orange),
                overlayColor: WidgetStatePropertyAll(Colors.orange.shade100),
              ),
            )
          ]
        );
      } else {
        handleSubscribtion(!subscribed);
      }
    }
  }

  handleSubscribtion(bool willSubscribe) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Church>(context, listen: false).subscribe(
        widget.churchId,
        willSubscribe: willSubscribe
      ).then((value) async {
        showSnackBar(context: context, message: value, type: SnackBarType.success);
        await Provider.of<User>(context, listen: false).getUserData();
      });
    } on HttpException {
      showSnackBar(
        context: context,
        message: "L'opération a échoué !",
        type: SnackBarType.danger
      );
    } catch(e) {
      showSnackBar(
        context: context,
        message: "Une erreur inattendu est survenue",
        type: SnackBarType.danger
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  getChurch() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Church>(context, listen: false)
      .fetchChurch(widget.churchId)
      .then((value) => {
        setState(() {
          church = ChurchModel.fromJson(value['eglise']);
          members.clear();
          for(var member in value['members']) {
            members.add(UserModel.fromJson(member));
          }
          owner = UserModel.fromJson(value['user']);
        })
      });
    } catch(e) {
      e.printError();
      showSnackBar(
        context: context,
        message: "Une erreur inattendu est survenue !",
        type: SnackBarType.danger
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getChurch();
    _scrollController.addListener(() {
      _scrollController.offset < 150 ? setAlpha(0) : _scrollController.offset < 400 ? setAlpha(
        ((_scrollController.offset * 255) / 400).round()
      ) : setAlpha(255);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context).user!;
    bool subscribed = widget.churchId == user.churchId;

    print(alpha);

    return LoadingOverlay(
      isLoading: _isLoading,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: size.height * .4,
                toolbarHeight: 70,
                backgroundColor: Colors.grey.shade700,
                leading: BackButton(
                  color: Colors.white,
                ),
                title: Text(
                  church?.name ?? "",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white.withAlpha(alpha),
                    fontWeight: FontWeight.bold
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      image: church?.image == null ? null : DecorationImage(
                        image: NetworkImage(church!.image),
                        fit: BoxFit.cover
                      )
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withAlpha(60),
                            Colors.black.withAlpha(160)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter
                        )
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: size.height * .12, left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.grey.withAlpha(180),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: church?.logo != null ?
                                NetworkImage(church!.logo!) : null,
                              )
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(top: 40, bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    church?.name ?? "",
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FaIcon(FontAwesomeIcons.userTie, size: 16),
                                      SizedBox(width: 7),
                                      Text(
                                        owner?.name ?? "Inconnu",
                                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: Colors.white.withAlpha(170)
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
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
                              onPressed: () => onSubscribe(subscribed),
                              icon: FaIcon(
                                  subscribed ? FontAwesomeIcons.bookmark :
                                  FontAwesomeIcons.solidBookmark
                              ),
                              iconAlignment: IconAlignment.end,
                              label: Text(subscribed ? "Se désabonner" : "S'abonner"),
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    subscribed ? Colors.transparent : Colors.blue
                                  ),
                                  overlayColor: WidgetStateProperty.all(
                                    subscribed ? Colors.red.withAlpha(110)
                                      : Colors.white.withAlpha(110)
                                  ),
                                  iconColor: WidgetStateProperty.all(
                                    subscribed ? Colors.red : Colors.white
                                  ),
                                  foregroundColor: WidgetStateProperty.all(
                                    subscribed ? Colors.red : Colors.white
                                  ),
                                  shape: subscribed ? WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      side: const BorderSide(width: 2, color: Colors.red),
                                      borderRadius: BorderRadius.circular(100)
                                    )
                                  ) : null
                              ),
                            ),
                          ),
                        ),

                        customDataTile(
                          icon: FontAwesomeIcons.locationDot,
                          text: church?.address ?? "Chargement...",
                        ),
                        customDataTile(
                          icon: FontAwesomeIcons.phone,
                          text: church?.phone ?? "Chargement...",
                        ),
                        customDataTile(
                          icon: FontAwesomeIcons.solidEnvelope,
                          text: church?.email ?? "Chargement...",
                        )
                      ],
                    ),
                  )
                ),
                bottom: TabBar(
                    tabs: [
                      Tab(text: "Programme"),
                      Tab(text: "Céremonies"),
                      Tab(text: "Membres"),
                    ]
                ),
              ),
              SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: TabBarView(
                    children: [
                      Program(churchId: widget.churchId),
                      CeremonyShortList(churchId: widget.churchId),
                      Community(members: members, subscribed: subscribed),
                    ]
                  ),
                ),
              )
            ]
          )
        ),
      )
    );
  }

  Widget customDataTile({
    required IconData? icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.red,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelMedium!,
            ),
          )
        ],
      ),
    );
  }

  /*
  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: church == null ? Center(
            child: Text("Chargement..."),
          ) : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image de présentation de l'église
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image: NetworkImage(church!.image),
                          fit: BoxFit.cover)),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(25),
                              Colors.black.withAlpha(160)
                            ])),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.black.withAlpha(75),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.grey,
                            backgroundImage: church!.logo != null
                                ? NetworkImage(church!.logo!)
                                : const AssetImage("assets/images/bg-5.jpg"),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                                child: Text(
                              church!.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                              overflow: TextOverflow.clip,
                            )),
                            const SizedBox(height: 7),
                            Text(
                              owner != null
                              ? owner!.name
                              : "Inconnu",
                              style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(color: Colors.white.withAlpha(170)),
                              overflow: TextOverflow.clip,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_pin,
                              size: 15,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                church!.address,
                                style: Theme.of(context).textTheme.labelMedium!,
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.phone,
                              size: 12,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                church!.phone,
                                style: Theme.of(context).textTheme.labelMedium!,
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.solidEnvelope,
                              size: 12,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                church!.email,
                                style: Theme.of(context).textTheme.labelMedium!,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextButton.icon(
                      onPressed: () => onSubscribe(subscribed),
                      icon: FaIcon(
                        subscribed ? FontAwesomeIcons.bookmark :
                        FontAwesomeIcons.solidBookmark
                      ),
                      iconAlignment: IconAlignment.end,
                      label: Text(subscribed ? "Se désabonner" : "S'abonner"),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          subscribed ? Colors.transparent : Colors.blue
                        ),
                        overlayColor: WidgetStateProperty.all(
                          subscribed ? Colors.red.withAlpha(110)
                          : Colors.white.withAlpha(110)
                        ),
                        iconColor: WidgetStateProperty.all(
                          subscribed ? Colors.red : Colors.white
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          subscribed ? Colors.red : Colors.white
                        ),
                        shape: subscribed ? WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            side: const BorderSide(width: 2, color: Colors.red),
                            borderRadius: BorderRadius.circular(100)
                          )
                        ) : null
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 30),
                  child: Text(church!.description),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customNavitem(context,
                      currentIndex: _pageIndex, index: 0, label: "Programme"),
                    customNavitem(context,
                      currentIndex: _pageIndex, index: 1, label: "Céremonies"),
                    customNavitem(context,
                      currentIndex: _pageIndex, index: 2, label: "Membres"),
                  ],
                ),

                SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * .5,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (value) => setPageIndex(value),
                      children: [
                        Program(churchId: widget.churchId),
                        CeremonyShortList(churchId: widget.churchId),
                        Community(members: members, subscribed: subscribed),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
  */

  InkWell customNavitem(BuildContext context, {
    required int index,
    required String label,
    required int currentIndex
  }) {
    return InkWell(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      },
      child: AnimatedContainer(
        padding: const EdgeInsets.all(7),
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
            border: index == currentIndex
                ? const Border(
                    bottom: BorderSide(width: 5, color: Colors.green))
                : null),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: index == currentIndex ? Colors.green : null),
        ),
      ));
  }
}
