import 'dart:io';
import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/models/post_model.dart';
import 'package:aesd/models/user_model.dart';
import 'package:aesd/pages/social/create_form.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/provider/post.dart';
import 'package:aesd/schemas/post.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/structure.dart';

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late final UserModel? user;
  bool isLoading = false;

  Future onCreate(CreatePostSchem newPost) async {
    try {
      await Provider.of<PostProvider>(
        context,
        listen: false,
      ).create(await newPost.getFormData()).then((value) {
        MessageService.showSuccessMessage("Post ajouté avec succès");
        Get.back();
      });
    } on DioException {
      throw Exception("Erreur réseau. Vérifiez votre connexion internet");
    } on HttpException catch (e) {
      throw Exception(e.message);
    }
  }

  Future onLike(PostModel post) async {
    try {
      await Provider.of<PostProvider>(
        context,
        listen: false,
      ).likePost(post.id).then((value) {
        setState(() {
          post.likes = value['likeCount'];
          post.liked = value['like'];
        });
      });
    } on HttpException catch (e) {
      MessageService.showWarningMessage(e.message);
    } on DioException catch (e) {
      e.printError();
      MessageService.showErrorMessage(
        "Une erreur s'est produite, vérifiez la connexion internet et rééssayez",
      );
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur s'est produite");
    }
  }

  Future _getPosts() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<PostProvider>(context, listen: false).getPosts();
    } on HttpException catch (e) {
      MessageService.showWarningMessage(e.message);
    } on DioException catch (e) {
      e.printError();
      MessageService.showErrorMessage(
        "Une erreur s'est produite, vérifiez la connexion internet et rééssayez",
      );
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur s'est produite");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    user = Provider.of<Auth>(context, listen: false).user;
    final posts = Provider.of<PostProvider>(context, listen: false).posts;
    if (posts.isEmpty) {
      _getPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child:
                  isLoading
                      ? ListShimmerPlaceholder()
                      : Consumer<PostProvider>(
                        builder: (context, provider, child) {
                          if (provider.posts.isEmpty) {
                            return notFoundTile(
                              text: "Aucun post pour le moment",
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () async => await _getPosts(),
                            child: ListView.builder(
                              itemCount: provider.posts.length,
                              itemBuilder: (context, index) {
                                var current = provider.posts[index];
                                return current.buildWidget(
                                  context,
                                  onLike: onLike,
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
            if (isLoading) loadingBar(),
          ],
        ),

        // bouton flottant
        if (user != null && user!.accountType.code == Dictionnary.servant.code)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed:
                    () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder:
                          (context) => CreatePost(
                            canPickImage: true,
                            onSubmit: (createObj) => onCreate(createObj),
                            pictureValidator: (pic, content) {
                              if (pic == null &&
                                  (content == null || content.isEmpty)) {
                                throw Exception(
                                  "Le post ne peut être vide. Ajoutez une image ou du texte",
                                );
                              }
                            },
                          ),
                    ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 3,
                child: cusFaIcon(FontAwesomeIcons.feather, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
