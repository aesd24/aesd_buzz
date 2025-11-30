import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/pages/social/create_form.dart';
import 'package:aesd/provider/forum.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DiscutionSubjectPage extends StatefulWidget {
  const DiscutionSubjectPage({super.key});

  @override
  State<DiscutionSubjectPage> createState() => _DiscutionSubjectPageState();
}

class _DiscutionSubjectPageState extends State<DiscutionSubjectPage> {
  bool _isLoading = true;
  bool _likeLoading = false;
  bool _isExpanded = false;
  int? subjectId;

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> loadSubject(int id) async {
    try {
      await Provider.of<Forum>(context, listen: false).getAny(id);
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Verifiez votre connexion et rééssayez",
      );
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu est survenue");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> likeSubject(int id) async {
    try {
      setState(() {
        _likeLoading = true;
      });
      await Provider.of<Forum>(
        context,
        listen: false,
      ).likeSubject(subjectId: id);
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Verifiez votre connexion et rééssayez",
      );
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu est survenue");
    } finally {
      setState(() {
        _likeLoading = false;
      });
    }
  }

  Future makeComment(int id, String comment) async {
    try {
      setState(() {
        _isLoading = true;
      });
      bool result = await Provider.of<Forum>(
        context,
        listen: false,
      ).makeComment(subjectId: id, comment: comment);
      if (result) {
        await Provider.of<Forum>(context, listen: false).getAny(id);
        MessageService.showSuccessMessage("Votre commentaire a été envoyé !");
        Get.back();
      }
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Vérifiez votre connexion internet et rééssayez",
      );
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendu est survenue.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      subjectId = Get.arguments['id'] as int;
      await loadSubject(subjectId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
          body: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
        )
        : Consumer<Forum>(
          builder: (context, provider, child) {
            if (provider.selectedSubject == null) {
              return Scaffold(
                body: Center(
                  child: notFoundTile(
                    icon: FontAwesomeIcons.personCircleExclamation,
                    text: "Impossible de récupérer le sujet",
                  ),
                ),
              );
            }
            final subject = provider.selectedSubject!;
            return Scaffold(
              body: RefreshIndicator(
                onRefresh: () async {
                  await loadSubject(subjectId!);
                },
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      toolbarHeight: 90,
                      backgroundColor: Color.fromRGBO(0, 17, 0, 1),
                      foregroundColor: Colors.white,
                      leading: customBackButton(color: Colors.white),
                      expandedHeight: 300,
                      pinned: true,
                      actions: [
                        Text(
                          formatDate(subject.createdAt, withTime: false),
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(color: Colors.white60),
                        ),
                        SizedBox(width: 10),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        title: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            subject.title,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        background: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/bg_forum.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withAlpha(170),
                                  Colors.black.withAlpha(70),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    width: 1.5,
                                    color:
                                        !subject.isClosed
                                            ? Colors.green
                                            : Colors.amber,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 15,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundImage: AssetImage(
                                              "assets/icons/launcher_icon.png",
                                            ),
                                            backgroundColor: Colors.white,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                            ),
                                            child: Text(
                                              "Contexte de la discussion",
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium!.copyWith(
                                                    color: notifire.getMainText
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      subject.body,
                                      style: Theme.of(
                                        context
                                      ).textTheme.bodyMedium!.copyWith(
                                        color: notifire.getMainText.withAlpha(
                                          200,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Positioned(
                                top: -5,
                                left: -5,
                                child: CircleAvatar(
                                  radius: 7,
                                  backgroundColor:
                                      !subject.isClosed
                                          ? Colors.green
                                          : Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    subject.comments.isNotEmpty
                        ? SliverList.builder(
                          itemCount: subject.comments.length,
                          itemBuilder:
                              (context, index) =>
                                  subject.comments[index].getWidget(context),
                        )
                        : SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Center(
                              child: Text(
                                "Aucun commentaire pour le moment",
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: Colors.black54),
                              ),
                            ),
                          ),
                        ),
                    SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
              floatingActionButton:
                  !subject.isClosed
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_isExpanded) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: TextButton.icon(
                                onPressed:
                                    () async => await likeSubject(subject.id),
                                icon:
                                    _likeLoading
                                        ? SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                          ),
                                        )
                                        : FaIcon(
                                          subject.isLiked
                                              ? FontAwesomeIcons.solidHeart
                                              : FontAwesomeIcons.heart,
                                          size: 18,
                                        ),
                                label: Text(subject.likes.toString()),
                                style: ButtonStyle(
                                  foregroundColor: WidgetStatePropertyAll(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                  iconColor: WidgetStatePropertyAll(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                  backgroundColor: WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                  elevation: WidgetStatePropertyAll(3),
                                  shadowColor: WidgetStatePropertyAll(
                                    Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(70),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: IconButton(
                                onPressed:
                                    () => showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder:
                                          (context) => CreatePost(
                                            onSubmit:
                                                (comment) => makeComment(
                                                  subject.id,
                                                  comment.content,
                                                ),
                                          ),
                                    ),
                                icon: FaIcon(
                                  FontAwesomeIcons.solidComment,
                                  size: 18,
                                ),
                                style: ButtonStyle(
                                  foregroundColor: WidgetStatePropertyAll(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                  iconColor: WidgetStatePropertyAll(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                  backgroundColor: WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                  elevation: WidgetStatePropertyAll(3),
                                  shadowColor: WidgetStatePropertyAll(
                                    Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(70),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          FloatingActionButton(
                            onPressed: () => _toggle(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: Icon(
                              _isExpanded
                                  ? FontAwesomeIcons.xmark
                                  : FontAwesomeIcons.plus,
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      )
                      : null,
            );
          },
        );
  }
}
