import 'dart:io';
import 'package:aesd/models/ceremony.dart';
import 'package:aesd/requests/ceremony_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Ceremonies extends ChangeNotifier {
  final _handler = CeremonyRequest();
  final List<CeremonyModel> _ceremonies = [];
  CeremonyModel? _selectedCeremony;
  CeremonyModel? get selectedCeremony => _selectedCeremony;

  List<CeremonyModel> get ceremonies => _ceremonies;

  Future all({required int churchId}) async {
    final response = await _handler.getAll(churchId);
    print(response.data);
    if (response.statusCode == 200){
      _ceremonies.clear();
      for (var element in response.data['data']){
        _ceremonies.add(CeremonyModel.fromJson(element));
      }
      notifyListeners();
    }
    else {
      throw HttpException("Impossible d'obtenir la liste des cérémonies");
    }
  }

  Future delete({required CeremonyModel element}) async {
    final response = await _handler.delete(element.id);
    print(response.data);
    if (response.statusCode == 200){
      _ceremonies.remove(element);
      return true;
    }
    else {
      throw HttpException("Impossible de supprimer cet évènement");
    }
  }

  Future create(Map<String, dynamic> data) async {
    var body = FormData.fromMap({
      "title" : data['title'],
      "description" : data['description'],
      "event_date": data['date'],
      "media" : await MultipartFile.fromFile(data['movie']),
      "id_eglise": data['church_id'],
    });

    var response = await _handler.create(body);
    print(response);
    if (response.statusCode == 201) {
      return response.data;
    } else {
      throw HttpException("erreur: ${response.data['message']}");
    }
  }

  Future update(Map<String, dynamic> data, {required int id}) async {
    var body = FormData.fromMap({
      "title" : data['title'],
      "description" : data['description'],
      "event_date": data['date'],
      if (data["media"] != null) "media" : await MultipartFile.fromFile(data['movie']),
      "id_eglise": data['church_id'],
    });

    var response = await _handler.update(id, body);
    print(response);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw HttpException("erreur: ${response.data['message']}");
    }
  }

  Future ceremonyDetail(int id) async {
    final response = await _handler.detail(id);
    if (response.statusCode == 200){
      _selectedCeremony = CeremonyModel.fromJson(response.data['data']);
      notifyListeners();
    } else {
      throw HttpException("Impossible de récupérer la cérémonie");
    }
  }
}