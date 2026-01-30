import 'dart:async';
import 'dart:io';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/models/membership_request.dart';
import 'package:aesd/models/servant_model.dart';
import 'package:aesd/models/user_model.dart';
import 'package:aesd/requests/church_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Church extends ChangeNotifier {
  final int _currentPage = 0;
  final ChurchRequest _request = ChurchRequest();
  final List<ChurchModel> _churches = [];
  final List<ChurchModel> _userChurches = [];
  final List<ChurchModel> _allChurchesRaw = []; // Liste interne complete pour les scans
  ChurchModel? _selectedChurch;

  ChurchModel? get selectedChurch => _selectedChurch;
  List<ChurchModel> get churches => _churches;
  List<ChurchModel> get userChurches => _userChurches;

  Future getUserChurches() async {
    final response = await _request.userChurches();
    print(response);
    if (response.statusCode == 200) {
      final mainChurches = response.data['data']['main_churches'];
      final secondaries = response.data['data']['secondary_churches'];
      final subscribed = response.data['data']['subscribed_church'];

      _userChurches.clear();
      for (var church in mainChurches) {
        _userChurches.add(ChurchModel.fromJson(church));
      }
      for (var church in secondaries) {
        _userChurches.add(ChurchModel.fromJson(church));
      }
      // Ajouter l'église assignée (annexe) si elle existe
      if (subscribed != null) {
        _userChurches.add(ChurchModel.fromJson(subscribed));
      }
    } else {
      throw HttpException("erreur : ${response.data['message']}");
    }
    notifyListeners();
  }

  Future fetchChurches() async {
    final response = await _request.all(page: _currentPage);
    if (response.statusCode == 200) {
      final allChurches =
          (response.data['data'] as List)
              .map((e) => ChurchModel.fromJson(e))
              .toList();
      
      _allChurchesRaw.clear();
      _allChurchesRaw.addAll(allChurches);
      
      // On garde TOUTES les églises dans la liste brute, mais on filtre pour l'affichage
      if (_churches.isNotEmpty && _currentPage == 0) {
        _churches.clear();
      }
      
      // On ne garde que les églises principales pour l'affichage de la liste globale
      final mainChurches = allChurches
          .where((church) => church.isMain || church.mainChurchId == null)
          .toList();
          
      _churches.addAll(mainChurches);
      
      print("Global church list updated: ${_churches.length} main churches displayed. Total raw: ${_allChurchesRaw.length}");
      notifyListeners();
    }
  }

  Future fetchChurch(int id) async {
    final response = await _request.one(id);
    print("CHURCH DEBUG - ID: $id, Response: ${response.data}");
    
    if (response.statusCode == 200) {
      final data = response.data['data'];
      _selectedChurch = ChurchModel.fromJson(data['church']);
      
      // LOGIQUE DE SCAN GLOBALE: On cherche l'annexe Bimbresso partout !
      print("CHURCH DEBUG - Scanning internal raw list for annexes of $id...");
      final allSubChurches = _allChurchesRaw.where((c) => c.mainChurchId == id).toList();
      
      // Fusionner les annexes de l'API avec celles trouvées localement
      for (var sub in allSubChurches) {
        if (!_selectedChurch!.annexes.any((a) => a.id == sub.id)) {
          _selectedChurch!.annexes.add(sub);
        }
      }

      print("CHURCH DEBUG - Total annexes after scan: ${_selectedChurch!.annexes.length}");
      _selectedChurch!.owner = ServantModel.fromJson(data['owner']);
      _selectedChurch!.members =
          (data['members'] as List).map((e) => UserModel.fromJson(e)).toList();
      notifyListeners();
      return true;
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

    final response = await _request.create(formData);
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

  Future retryValidateChurch(int churchId, File attestationFile) async {
    FormData formData = FormData.fromMap({
      'attestation_file_path': await MultipartFile.fromFile(
        attestationFile.path,
      ),
    });
    final response = await _request.retryValidation(churchId, data: formData);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw HttpException("Impossible d'envoyer l'attestation");
    }
  }

  Future membershipRequest(int churchId) async {
    final response = await _request.requestMembership(churchId: churchId);
    if (response.statusCode == 200) {
      return "Demande d'adhésion soumise";
    } else {
      throw HttpException("Impossible de rejoindre cette église");
    }
  }

  Future getMembershipRequests() async {
    final response = await _request.getMembershipRequests();
    if (response.statusCode == 200) {
      print(response.data);
      final data = response.data['data'];
      final List<MembershipRequestModel> requests = [];
      for (var request in data) {
        requests.add(MembershipRequestModel.fromJson(request));
      }
      return requests;
    } else {
      throw HttpException("Impossible de récupérer les demandes d'adhésion");
    }
  }

  Future acceptMembershipRequest(int requestId) async {
    final response = await _request.acceptMembershipRequest(requestId);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw HttpException("Impossible d'accepter la demande d'adhésion");
    }
  }

  Future rejectMembershipRequest(int requestId) async {
    final response = await _request.rejectMembershipRequest(requestId);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw HttpException("Impossible de rejeter la demande d'adhésion");
    }
  }
}
