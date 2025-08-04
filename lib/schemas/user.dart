import 'dart:io';
import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:dio/dio.dart';

class UserCreate {
  final String name;
  final String email;
  final String phone;
  final String adress;
  final String accountType;
  final String password;
  final String passwordConfirmation;
  final bool terms;
  final String? description;
  final String? call;
  final String? manager;
  final File? idPicture;
  final File? idCardRecto;
  final File? idCardVerso;

  const UserCreate({
    required this.name,
    required this.email,
    required this.phone,
    required this.adress,
    required this.accountType,
    required this.password,
    required this.passwordConfirmation,
    required this.terms,
    this.description,
    this.call,
    this.manager,
    this.idPicture,
    this.idCardRecto,
    this.idCardVerso,
  });

  Future<FormData> getFormData() async => FormData.fromMap({
    "name": name,
    "email": email,
    "phone": phone,
    "adresse": adress,
    "account_type": accountType,
    "password": password,
    "password_confirmation": passwordConfirmation,
    "terms": terms,
    "description": description,
    "appel": call,
    "manager": manager,
    "profile_photo": accountType == Dictionnary.servant.code ?
      await MultipartFile.fromFile(idPicture!.path) : null,
    "id_card_recto": accountType == Dictionnary.servant.code ?
      await MultipartFile.fromFile(idCardRecto!.path) : null,
    "id_card_verso": accountType == Dictionnary.servant.code ?
      await MultipartFile.fromFile(idCardVerso!.path) : null,
  });
}

class UserLogin {
  final String login;
  final String password;
  final String deviceName;
  final String deviceToken;

  const UserLogin({
    required this.login,
    required this.password,
    required this.deviceName,
    required this.deviceToken,
  });

  Future<FormData> getFormData() async => FormData.fromMap({
    "user_info": login,
    "password": password,
    "device_token": deviceToken,
    "device_name": deviceName,
  });
}