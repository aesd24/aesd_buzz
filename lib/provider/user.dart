import 'dart:io';

import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:aesd/models/user_model.dart';
import 'package:aesd/requests/user_request.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final _handler = UserRequest();

  UserModel? _selectedUser;
  UserModel? get selectedUser => _selectedUser;

  Future getUser(int userId) async {
    final response = await _handler.getUser(userId);
    if (response.statusCode == 200) {
      _selectedUser = UserModel.fromJson(response.data);
    } else {
      throw HttpException("Impossible de récupérer l'utilisateur");
    }
  }
}