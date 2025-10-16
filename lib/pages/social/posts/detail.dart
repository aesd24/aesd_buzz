import 'dart:io';

import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/image_viewer.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/models/post_model.dart';
import 'package:aesd/pages/social/create_form.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/provider/post.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PostDetail extends StatefulWidget {
  const PostDetail({super.key});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  bool isLoading = true;

  Future loadPost(int postId) async {
    try {
      await Provider.of<PostProvider>(
        context,
        listen: false,
      ).postDetail(postId);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. vérifiez votre connexion internet",
      );
    } /*catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendu s'est produite !");
    }*/ finally {
      setState(() {
        isLoading = false;
      });
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

  Future makeComment(int postId, String comment) async {
    try {
      await Provider.of<PostProvider>(
        context,
        listen: false,
      ).makeComment(postId, comment).then((value) async {
        await Provider.of<PostProvider>(
          context,
          listen: false,
        ).postDetail(postId);
        MessageService.showSuccessMessage("Commentaire envoyé !");
      });
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. vérifiez votre connexion internet",
      );
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu s'est produite !");
      e.printError();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var postId = Get.arguments['postId'];
      await loadPost(postId as int);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: customBackButton(),
        shape: Border(bottom: BorderSide(color: notifire.getMaingey, width: 1)),
        title: Text("Post"),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child:
            isLoading
                ? ListShimmerPlaceholder()
                : Consumer<PostProvider>(
                  builder: (context, provider, child) {
                    if (provider.selectedPost == null) {
                      return Center(
                        child: notFoundTile(
                          text: "Impossible de charger le post",
                        ),
                      );
                    }
                    final post = provider.selectedPost!;
                    post.author ??= Provider.of<Auth>(context, listen: false).user!;
                    return Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 17,
                                          backgroundColor:
                                              notifire.getMainColor,
                                          backgroundImage:
                                              post.author!.photo != null
                                                  ? FastCachedImageProvider(
                                                    post.author!.photo!,
                                                  )
                                                  : null,
                                          child:
                                              post.author!.photo != null
                                                  ? null
                                                  : cusFaIcon(
                                                    FontAwesomeIcons.solidUser,
                                                    color: notifire.getbgcolor,
                                                  ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(post.author!.name),
                                              Text(
                                                formatDate(post.date),
                                                style: textTheme.bodySmall!
                                                    .copyWith(
                                                      color: scheme.onSurface
                                                          .withAlpha(100),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (post.image != null) ...[
                                            GestureDetector(
                                              onTap:
                                                  () => Get.to(() =>
                                                    ImageViewer(
                                                      imageUrl: post.image!,
                                                    ),
                                                  ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: FastCachedImage(
                                                  fit: BoxFit.cover,
                                                  url: post.image!,
                                                  loadingBuilder: (
                                                    context,
                                                    progress,
                                                  ) {
                                                    return imageShimmerPlaceholder(
                                                      height: 200,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 25),
                                          ],
                                          Text(
                                            post.content,
                                            style: textTheme.bodyLarge!
                                                .copyWith(
                                                  color: notifire.getMainText,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    customActionButton(
                                      onPressed: () => onLike(post),
                                      cusFaIcon(
                                        post.liked
                                            ? FontAwesomeIcons.solidHeart
                                            : FontAwesomeIcons.heart,
                                        color:
                                            post.liked
                                                ? Colors.red
                                                : notifire.getMainText,
                                      ),
                                      post.likes == 0
                                          ? "J'aime"
                                          : "${post.likes} like${post.likes == 1 ? "" : "s"}",
                                    ),
                                    SizedBox(width: 15),
                                    customActionButton(
                                      cusFaIcon(
                                        FontAwesomeIcons.comment,
                                        color: notifire.getMainText,
                                      ),
                                      post.comments == 0
                                          ? "Commenter"
                                          : "${post.comments} Commentaire${post.comments == 1 ? "" : "s"}",
                                      onPressed:
                                          () => showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder:
                                                (context) => CreatePost(
                                                  onSubmit: (createObj) async {
                                                    await makeComment(
                                                      post.id,
                                                      createObj.content,
                                                    );
                                                    Get.back();
                                                  },
                                                ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(color: notifire.getMaingey, thickness: 1),
                              Column(
                                children: List.generate(
                                  provider.comments.length,
                                  (index) {
                                    var current = provider.comments[index];
                                    return current.buildWidget(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
      ),
    );
  }
}
