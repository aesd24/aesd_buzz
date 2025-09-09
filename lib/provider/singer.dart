import 'dart:io';
import 'package:aesd/models/singer_model.dart';
import 'package:aesd/requests/singer_request.dart';
import 'package:flutter/material.dart';

class Singer extends ChangeNotifier {
  final SingerRequest _request = SingerRequest();
  final List<SingerModel> _singers = [];
  List<SingerModel> get singers => _singers;

  Future fetchSingers() async {
    final response = await _request.all();

    if (response.statusCode == 200){
      _singers.clear();
      for (var singers in response.data['chantres']) {
        _singers.add(SingerModel.fromJson(singers));
      }
    } else {
      throw HttpException(response.data['message']);
    }
    notifyListeners();
  }
}
