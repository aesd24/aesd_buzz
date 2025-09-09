import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/provider/post.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CommentPages extends StatefulWidget {
  const CommentPages({super.key, required this.postId});

  final int postId;

  @override
  State<CommentPages> createState() => _CommentPagesState();
}

class _CommentPagesState extends State<CommentPages> {
  bool isLoading = false;
  bool isCommenting = false;
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  Future loadPost() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<PostProvider>(
        context,
        listen: false,
      ).postDetail(widget.postId);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. vérifiez votre connexion internet",
      );
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu est survenu !");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future makeComment() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isCommenting = true;
        });
        await Future.delayed(Duration(seconds: 1), () async {
          await Provider.of<PostProvider>(context, listen: false)
              .makeComment(widget.postId, _commentController.text)
              .then((value) async {
                await Provider.of<PostProvider>(
                  context,
                  listen: false,
                ).postDetail(widget.postId).then((value) {
                  setState(() {
                    isCommenting = false;
                  });
                });
                FocusScope.of(context).unfocus();
                _commentController.clear();
                MessageService.showSuccessMessage("Commentaire envoyé !");
              });
        });
      } on DioException {
        MessageService.showErrorMessage(
          "Erreur réseau. vérifiez votre connexion internet",
        );
      } on HttpException catch (e) {
        MessageService.showErrorMessage(e.message);
      } catch (e) {
        MessageService.showErrorMessage(
          "Une erreur inattendu s'est produite !",
        );
        e.printError();
      } finally {
        setState(() {
          isCommenting = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadPost();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      constraints: BoxConstraints(maxHeight: size.height * 0.8),
      decoration: BoxDecoration(
        color: notifire.getbgcolor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text("Commentaires"),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: cusFaIcon(FontAwesomeIcons.chevronDown),
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child:
                  isLoading
                      ? CommentsPlaceholder()
                      : Consumer<PostProvider>(
                        builder: (context, provider, child) {
                          if (provider.comments.isEmpty) {
                            return notFoundTile(
                              text: "Aucun commentaire",
                              icon: FontAwesomeIcons.comments,
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () async => loadPost(),
                            child: ListView.builder(
                              itemCount: provider.comments.length,
                              itemBuilder: (context, index) {
                                var current = provider.comments[index];
                                return current.buildWidget(context);
                              },
                            ),
                          );
                        },
                      ),
            ),
            if (!isLoading)
              Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: CustomFormTextField(
                    controller: _commentController,
                    label: 'Ecrivez votre commentaire...',
                    type: TextInputType.multiline,
                    validate: true,
                    suffix:
                        isCommenting
                            ? Container(
                              padding: EdgeInsets.all(10),
                              width: 5,
                              height: 5,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                              ),
                            )
                            : IconButton(
                              onPressed: () async => makeComment(),
                              icon: cusIcon(
                                FontAwesomeIcons.solidPaperPlane,
                                color: notifire.getMainColor,
                              ),
                            ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
