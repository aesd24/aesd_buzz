import 'dart:io';

import 'package:dio/dio.dart';

class CreatePostSchem {
  late String? content;
  late File? image;

  CreatePostSchem({this.content, this.image});

  Future getFormData() async => FormData.fromMap({
    "contenu": content,
    "image": image != null ? await MultipartFile.fromFile(image!.path) : null,
  });
}
