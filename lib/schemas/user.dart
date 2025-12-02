import 'dart:io';
import 'package:aesd/appstaticdata/dictionnary.dart';
import 'package:dio/dio.dart';

class UserCreate {
  final String? name;
  final String? email;
  final String? phone;
  final String? adress;
  final String? accountType;
  final String? password;
  final String? passwordConfirmation;
  final bool? terms;
  final String? description;
  final String? call;
  final String? manager;
  late File? idPicture;
  late File? idCardRecto;
  late File? idCardVerso;

  UserCreate({
    this.name,
    this.email,
    this.phone,
    this.adress,
    this.accountType,
    this.password,
    this.passwordConfirmation,
    this.terms,
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
    "profile_photo":
        accountType == Dictionnary.servant.code
            ? await MultipartFile.fromFile(idPicture!.path)
            : null,
    "id_card_recto":
        accountType == Dictionnary.servant.code
            ? await MultipartFile.fromFile(idCardRecto!.path)
            : null,
    "id_card_verso":
        accountType == Dictionnary.servant.code
            ? await MultipartFile.fromFile(idCardVerso!.path)
            : null,
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

class UserCertif {
  late File? idPicture;
  late File? idCardRecto;
  late File? idCardVerso;

  UserCertif({this.idPicture, this.idCardRecto, this.idCardVerso});

  Future<FormData> getFormData() async => FormData.fromMap({
    "profile_photo": await MultipartFile.fromFile(idPicture!.path),
    "id_card_recto": await MultipartFile.fromFile(idCardRecto!.path),
    "id_card_verso": await MultipartFile.fromFile(idCardVerso!.path),
  });
}
