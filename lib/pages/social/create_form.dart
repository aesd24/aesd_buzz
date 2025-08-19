import 'dart:io';

import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/bottom_sheets.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/image_container.dart';
import 'package:aesd/schemas/post.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({
    super.key,
    required this.title,
    this.placeholder,
    this.canPickImage = false,
    this.canPickVideo = false,
    this.pictureValidator,
    this.videoValidator,
    this.onSubmit,
  });

  final String title;
  final String? placeholder;
  final bool canPickImage;
  final void Function(File?, String?)? pictureValidator;
  final void Function(File?, String?)? videoValidator;
  final bool canPickVideo;
  final dynamic Function(CreatePostSchem)? onSubmit;

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  bool _isLoading = false;
  final _contentController = TextEditingController();

  File? image;
  File? video;

  // functions
  Future _submitForm() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_contentController.text.isEmpty) {
        MessageService.showWarningMessage(
          "Ecrivez quelque chose s'il vous plaît !",
        );
        return;
      }

      if (widget.pictureValidator != null) {
        widget.pictureValidator!(image, _contentController.text);
      }

      if (widget.videoValidator != null) {
        widget.videoValidator!(video, _contentController.text);
      }

      if (widget.onSubmit != null) {
        await widget.onSubmit!(CreatePostSchem(
          content: _contentController.text,
          image: image
        ));
      }
    } catch (e) {
      MessageService.showErrorMessage(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: cusFaIcon(FontAwesomeIcons.chevronDown),
        ),
        title: Text(widget.title, style: mainTextStyle),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child:
                _isLoading
                    ? SizedBox(
                      height: 23,
                      width: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                    : IconButton(
                      onPressed: () async => await _submitForm(),
                      icon: FaIcon(FontAwesomeIcons.paperPlane),
                      style: ButtonStyle(
                        iconSize: WidgetStatePropertyAll(20),
                        iconColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // boutons d'ajout de fichiers
              Row(
                children: [
                  if (widget.canPickImage && image == null && video == null)
                    IconButton(
                      onPressed:
                          () => pickModeSelectionBottomSheet(
                            context: context,
                            setter: (value) {
                              try {
                                setState(() {
                                  image = value;
                                });
                              } catch (e) {
                                MessageService.showWarningMessage(e.toString());
                              }
                            },
                          ),
                      icon: SvgPicture.asset("assets/icons/image.svg"),
                    ),
                  if (widget.canPickVideo && image == null && video == null)
                    IconButton(
                      onPressed:
                          () => pickModeSelectionBottomSheet(
                            photo: false,
                            context: context,
                            setter: (value) {
                              try {
                                setState(() {
                                  video = value;
                                });
                              } catch (e) {
                                MessageService.showWarningMessage(e.toString());
                              }
                            },
                          ),
                      icon: SvgPicture.asset("assets/icons/video.svg"),
                    ),
                ],
              ),

              // Image, si ajouté
              if (image != null)
                postImage(
                  context,
                  image!,
                  onRemove: () => setState(() => image = null),
                ),
              SizedBox(height: 15),

              // Champ pour l'ajout de text
              Scrollbar(
                child: TextField(
                  controller: _contentController,
                  minLines: 1,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: widget.placeholder ?? "Quoi de neuf ?",
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
