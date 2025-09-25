import 'dart:async';
import 'dart:io';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/requests/church_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Church extends ChangeNotifier {
  final int _currentPage = 0;
  late ChurchPaginator _paginator;
  final ChurchRequest _request = ChurchRequest();
  final List<ChurchModel> _churches = [];
  final List<ChurchModel> _userChurches = [];

  List<ChurchModel> get churches => _churches;
  List<ChurchModel> get userChurches => _userChurches;

  Future getUserChurches() async {
    final response = await _request.userChurches();
    if (response.statusCode == 200) {
      var data = response.data['data']['churches'];
      _userChurches.clear();
      for (var church in data) {
        _userChurches.add(ChurchModel.fromJson(church));
      }
    } else {
      throw HttpException("erreur : ${response.data['message']}");
    }
    notifyListeners();
  }

  Future fetchChurches() async {
    final response = await _request.all(page: _currentPage);
    if (response.statusCode == 200) {
      final churches =
          (response.data['data'] as List)
              .map((e) => ChurchModel.fromJson(e))
              .toList();
      //_paginator = ChurchPaginator.fromJson(data);
      if (_churches.isNotEmpty && _currentPage == 0) {
        _churches.clear();
      }
      _churches.addAll(churches);

      notifyListeners();
    }
  }

  Future fetchChurch(int id) async {
    var response = await _request.one(id);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception("Impossible de récupérer l'église");
    }
  }

  Future update(int id, {required Map<String, dynamic> data}) async {
    FormData formData = FormData.fromMap({
      'name': data['name'],
      'adresse': data['location'],
      'phone': data['phone'],
      'email': data['email'],
      'description': data['description'],
      'type_church': data['churchType'],
      'logo': await MultipartFile.fromFile(data['image'].path),
    });
    var response = await _request.update(churchId: id, formData);
    print(response);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw const HttpException(
        "La modification de l'église à échoué. Rééssayez",
      );
    }
  }

  Future create({required Map<String, dynamic> data}) async {
    FormData formData = FormData.fromMap({
      'name': data['name'],
      'adresse': data['location'],
      'phone': data['phone'],
      'email': data['email'],
      'description': data['description'],
      'type_church': data['churchType'],
      'logo': await MultipartFile.fromFile(data['image'].path),
      'attestation_file_path': await MultipartFile.fromFile(
        data['attestation_file'].path,
      ),
      'is_main': data['isMain'],
      'main_church_id': data['mainChurchId'],
    });

    var response = await _request.create(formData);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw const HttpException("La création de l'église à échoué. Rééssayez");
    }
  }

  Future subscribe(int id, {required bool willSubscribe}) async {
    var response = await _request.subscribe(id, willSubscribe: willSubscribe);
    if (response.statusCode == 200) {
      return response.data['message'];
    } else {
      throw const HttpException("L'inscription à l'église à échoué.");
    }
  }
}
