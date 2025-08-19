import 'dart:io';
import 'package:aesd/models/forum_model.dart';
import 'package:aesd/requests/forum_request.dart';
import 'package:flutter/material.dart';

class Forum extends ChangeNotifier {
  final _requestHandler = ForumRequest();
  final List<ForumModel> _subjectsList = [];
  List<ForumModel> get subjects => _subjectsList;
  ForumModel? _selectedSubject;
  ForumModel? get selectedSubject => _selectedSubject;

  Future getAll() async {
    final response = await _requestHandler.getAll();
    if (response.statusCode == 200) {
      List subjects = response.data;
      _subjectsList.clear();
      subjects.map((e) => _subjectsList.add(ForumModel.fromJson(e))).toList();
      notifyListeners();
    } else {
      throw HttpException("Impossible de récupérer les sujets.");
    }
  }

  Future getAny(int id) async {
    final response = await _requestHandler.getAny(newsId: id);
    if (response.statusCode == 200) {
      _selectedSubject = ForumModel.fromJson(response.data['sujet']);
      notifyListeners();
    } else {
      throw HttpException("Impossible de récupérer les détails.");
    }
  }

  Future makeComment({required int subjectId, required String comment}) async {
    final response = await _requestHandler.makeComment(
        subjectId: subjectId,
        comment: comment
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw HttpException("Le commentaire n'a pas été créé. Rééssayez !");
    }
  }

  Future likeSubject({required int subjectId}) async {
    final response = await _requestHandler.likeSubject(subjectId: subjectId);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw HttpException("Le sujet n'a pas été liké. Rééssayez !");
    }
  }
}