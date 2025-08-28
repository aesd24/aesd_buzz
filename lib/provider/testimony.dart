import 'dart:io';
import 'package:aesd/models/testimony.dart';
import 'package:flutter/cupertino.dart';
import '../requests/testimony.dart';
import 'package:dio/dio.dart';

class Testimony extends ChangeNotifier {
  final _request = TestimonyRequest();
  final List<TestimonyModel> _testimonies = [];
  List<TestimonyModel> get testimonies => _testimonies;

  Future getAll() async {
    final response = await _request.all();
    if (response.statusCode != 200) {
      return HttpException(response.message);
    }
    _testimonies.clear();
    for (var piece in response.data) {
      _testimonies.add(TestimonyModel.fromJson(piece));
    }
    notifyListeners();
  }

  Future create(Map<String, dynamic> data) async {
    final formData = FormData.fromMap({
      'title': data['title'],
      'is_anonymous': data['is_anonymous'] ? 1 : 0,
      'confession_file_path': await MultipartFile.fromFile(data['media']),
      'user_id': data['user_id'],
      'mediaType': data['mediaType'],
    });
    final response = await _request.create(formData);
    if (response.statusCode != 201) {
      throw HttpException(response.data['message']);
    }
  }
}
