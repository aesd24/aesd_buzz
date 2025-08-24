import 'dart:io';
import 'package:aesd/models/servant_model.dart';
import 'package:aesd/requests/servant_request.dart';
import 'package:flutter/material.dart';

class Servant extends ChangeNotifier {
  final ServantRequest _request = ServantRequest();
  final List<ServantModel> _servants = [];

  List<ServantModel> get servants => _servants;

  Future getServant({required int servantId}) async {
    final response = await _request.one(servantId);
    if (response.statusCode == 200) {
      return response.data['serviteur'];
    } else {
      throw HttpException(response.data['message']);
    }
  }

  Future fetchServants() async {
    final response = await _request.all();

    if (response.statusCode == 200){
      _servants.clear();
      for (var servant in response.data['serviteurs']) {
        _servants.add(ServantModel.fromJson(servant));
      }
    } else {
      throw HttpException(response.data['message']);
    }
    notifyListeners();
  }

  Future subscribe({required int servantId, required bool subscribe}) async {
    final response = await _request.subscribe(servantId, subscribe);
    print(response);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw HttpException(response.data['message']);
    }
  }
}
