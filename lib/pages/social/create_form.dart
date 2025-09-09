import 'dart:io';

import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/bottom_sheets.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/image_container.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/schemas/post.dart';
import 'package:aesd/services/message.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({
    super.key,
    this.placeholder,
    this.canPickImage = false,
    this.canPickVideo = false,
    this.pictureValidator,
    this.videoValidator,
    this.onSubmit,
  });

  final String? placeholder;
  final bool canPickImage;
  final void Function(File?, String?)? pictureValidator;
  final void Function(File?, String?)? videoValidator;
  final bool canPickVideo;
  final dynamic Function(dynamic)? onSubmit;

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  bool _isLoading = false;
  final _focusNode = FocusNode();
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
        await widget.onSubmit!(
          CreatePostSchem(content: _contentController.text, image: image),
        );
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
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Auth>(context, listen: false).user!;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: notifire.getbgcolor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 70,
          leadingWidth: 100,
          leading: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: cusFaIcon(FontAwesomeIcons.chevronDown),
              ),
              Padding(
                padding: EdgeInsets.only(left: 3.0),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: notifire.getMainColor,
                  backgroundImage:
                      user.photo != null
                          ? FastCachedImageProvider(user.photo!)
                          : null,
                  child:
                      user.photo != null
                          ? null
                          : cusFaIcon(
                            FontAwesomeIcons.solidUser,
                            color: notifire.getbgcolor,
                          ),
                ),
              ),
            ],
          ),
          actions: [
            if (widget.canPickVideo &&
                image == null &&
                video == null)
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
                      MessageService.showWarningMessage(
                        e.toString(),
                      );
                    }
                  },
                ),
                icon: SvgPicture.asset("assets/icons/video.svg"),
              ),
            
            if (widget.canPickImage &&
                image == null &&
                video == null)
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
                      MessageService.showWarningMessage(
                        e.toString(),
                      );
                    }
                  },
                ),
                icon: SvgPicture.asset("assets/icons/image.svg"),
              ),
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
                      : CustomTextButton(
                        label: "Envoyer",
                        onPressed: () async => await _submitForm(),
                      ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Image, si ajouté
                if (image != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: postImage(
                      context,
                      image!,
                      onRemove: () => setState(() => image = null),
                    ),
                  ),

                // Champ pour l'ajout de text
                Scrollbar(
                  child: TextField(
                    controller: _contentController,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: widget.placeholder ?? "Quoi de neuf ?",
                      hintStyle: TextStyle(
                        color: notifire.getMainText.withAlpha(150)
                      ),
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
      ),
    );
  }
}
