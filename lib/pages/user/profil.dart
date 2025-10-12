import 'dart:io';
import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/appstaticdata/routes.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/functions/utilities.dart';
import 'package:aesd/pages/social/socialElementsList.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/provider/post.dart';
import 'package:aesd/provider/servant.dart';
import 'package:aesd/provider/testimony.dart';
import 'package:aesd/provider/user.dart';
import 'package:aesd/services/message.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class UserProfil extends StatefulWidget {
  const UserProfil({super.key});

  @override
  State<UserProfil> createState() => _UserProfilState();
}

class _UserProfilState extends State<UserProfil> {
  bool isLoading = true;
  bool subscribed = false;
  bool isSelf = false;

  Future getUser(int userId) async {
    try {
      setState(() => isLoading = true);
      await Provider.of<UserProvider>(context, listen: false).getUser(userId);
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur est survenue");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<dynamic> loadTestimonies() async {
    try {
      final results =
          await Provider.of<Testimony>(
            context,
            listen: false,
          ).getUserTestimonies();
      return results;
    } on HttpException {
      MessageService.showErrorMessage("L'opération à échoué !");
    }
  }

  Future<dynamic> loadPosts(int userId) async {
    try {
      final results = await Provider.of<PostProvider>(
        context,
        listen: false,
      ).getUserPosts(userId);
      return results;
    } on HttpException {
      MessageService.showErrorMessage("L'opération à échoué !");
    }
  }

  void onSubscribe(bool subscribed, {required int servantId}) async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Servant>(context, listen: false)
          .subscribe(servantId: servantId, subscribe: !subscribed)
          .then((value) async {
            setState(() {
              this.subscribed = !subscribed;
            });
            MessageService.showSuccessMessage(value['message']);
          });
    } on HttpException {
      MessageService.showErrorMessage("L'opération à échoué !");
    } catch (e) {
      MessageService.showErrorMessage("Une erreur est survenu !");
      e.printError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = Get.arguments['userId'];
      getUser(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      );
    }

    return Consumer<Auth>(
      builder: (context, provider, child) {
        final selfId = provider.user!.id;
        return Consumer<UserProvider>(
          builder: (context, provider, child) {
            final user = provider.selectedUser;
            if (user == null) {
              return Scaffold(
                appBar: AppBar(leading: customBackButton()),
                body: Center(
                  child: notFoundTile(text: "Utilisateur introuvable"),
                ),
              );
            }
            isSelf = user.id == selfId;
            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: size.height * 0.4,
                    leading: IconButton(
                      onPressed: () => Get.back(),
                      icon: cusFaIcon(
                        FontAwesomeIcons.arrowLeftLong,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor:
                        Colors.green, //Theme.of(context).colorScheme.surface,
                    automaticallyImplyLeading: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        color: Colors.green,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Hero(
                                    tag: "avatar",
                                    child: CircleAvatar(
                                      radius: 53,
                                      backgroundImage:
                                          user.photo != null
                                              ? FastCachedImageProvider(
                                                user.photo!,
                                              )
                                              : null,
                                      child:
                                          user.photo == null
                                              ? SvgPicture.asset(
                                                "assets/illustrations/user-avatar.svg",
                                              )
                                              : null,
                                    ),
                                  ),
                                  if (!isSelf &&
                                      !subscribed &&
                                      user.accountType.code ==
                                          Dictionnary.servant.code)
                                    Positioned(
                                      top: -13,
                                      right: -13,
                                      child: IconButton(
                                        onPressed:
                                            () => onSubscribe(
                                              subscribed,
                                              servantId: user.servant!.id,
                                            ),
                                        icon: FaIcon(
                                          FontAwesomeIcons.solidBookmark,
                                        ),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                Colors.blue,
                                              ),
                                          iconColor: WidgetStatePropertyAll(
                                            Colors.white,
                                          ),
                                          iconSize: WidgetStatePropertyAll(15),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  user.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.labelMedium!
                                    .copyWith(color: Colors.white70),
                              ),
                              if (!isSelf && subscribed)
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: TextButton(
                                    onPressed:
                                        () => onSubscribe(
                                          subscribed,
                                          servantId: user.servant!.id,
                                        ),
                                    style: ButtonStyle(
                                      foregroundColor: WidgetStatePropertyAll(
                                        Colors.red,
                                      ),
                                      backgroundColor: WidgetStatePropertyAll(
                                        Colors.red.withAlpha(50),
                                      ),
                                    ),
                                    child: Text("Me désabonner"),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // informations personnelles de l'utilisateur
                          Wrap(
                            spacing: 15,
                            runSpacing: 10,
                            children: [
                              _customRow(
                                icon: FontAwesomeIcons.solidEnvelope,
                                text: user.email,
                              ),
                              _customRow(
                                icon: FontAwesomeIcons.locationDot,
                                text: user.adress,
                              ),
                              _customRow(
                                icon: FontAwesomeIcons.phone,
                                text: user.phone,
                              ),
                              _customRow(
                                icon: FontAwesomeIcons.briefcase,
                                text: user.accountType.name,
                              ),
                            ],
                          ),

                          // biographie
                          Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Biographie",
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    /*if (isSelf)
                                    TextButton(
                                      onPressed: () {},
                                      child: Text("Ajouter"),
                                    ),*/
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Aucune biographie pour l'instant...",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(color: Colors.black45),
                                ),
                              ],
                            ),
                          ),

                          // Actions possible
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Actions",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                SizedBox(height: 10),
                                // actions sur le propre compte
                                if (isSelf) ...[
                                  _customActionButton(
                                    onPressed:
                                        () => Get.toNamed(Routes.updateUser),
                                    text: "Modifier mes informations",
                                    icon: FontAwesomeIcons.pen,
                                  ),
                                  _customActionButton(
                                    onPressed: () => Get.toNamed(Routes.forgot),
                                    text: "Modifier mon mot de passe",
                                    icon: FontAwesomeIcons.lockOpen,
                                  ),
                                  /*_customActionButton(
                                  text: "Voir mes transactions",
                                  icon: FontAwesomeIcons.moneyBillTransfer,
                                ),*/
                                  _customActionButton(
                                    onPressed:
                                        () => Get.to(
                                          () => SocialElementsList(
                                            loadElements: loadTestimonies,
                                          ),
                                        ),
                                    text: "Ecouter les témoignages",
                                    icon: FontAwesomeIcons.microphoneLines,
                                  ),
                                ],
                                _customActionButton(
                                  onPressed: () => openUserChurch(user),
                                  text: "Visiter l'église",
                                  icon: FontAwesomeIcons.church,
                                ),
                                if (user.accountType.code ==
                                    Dictionnary.servant.code) ...[
                                  _customActionButton(
                                    onPressed:
                                        () => Get.to(
                                          () => SocialElementsList(
                                            loadElements:
                                                () async => await loadPosts(
                                                  user.servant!.id,
                                                ),
                                          ),
                                        ),
                                    text: "Voir les posts",
                                    icon: FontAwesomeIcons.solidMessage,
                                  ),
                                  /*if (!isSelf)
                                  _customActionButton(
                                    text: "Payer la dime",
                                    icon: FontAwesomeIcons.circleDollarToSlot,
                                  ),*/
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _customActionButton({
    void Function()? onPressed,
    required String text,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: onPressed,
        leading: FaIcon(icon, size: 15),
        title: Text(text, style: Theme.of(context).textTheme.labelLarge),
        trailing: FaIcon(FontAwesomeIcons.chevronRight, size: 13),
      ),
    );
  }

  Widget _customRow({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FaIcon(icon, size: 13, color: Colors.black54),
        SizedBox(width: 5),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.labelMedium!.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}
