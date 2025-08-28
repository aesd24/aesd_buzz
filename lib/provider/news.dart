import 'dart:io';
import 'package:aesd/requests/news.dart';
import 'package:flutter/material.dart';
import '../models/news.dart';

class News extends ChangeNotifier {
  final _requestHandler = NewsRequest();
  final List<NewsModel> _newsList = [];
  List<NewsModel> get news => _newsList;
  NewsModel? _selectedNews;
  NewsModel? get selectedNews => _selectedNews;

  int _currentPage = 0;
  int totalPage = 0;
  int _limit = 10;

  Future getAll() async {
    final response = await _requestHandler.getAllNews(currentPage: _currentPage, limit: _limit);
    if (response.statusCode == 200) {
      List news = response.data;
      _newsList.clear();
      news.map((e) => _newsList.add(NewsModel.fromJson(e))).toList();
      notifyListeners();
    } else {
      throw HttpException("Impossible de récupérer les actualités.");
    }
  }

  Future getAny(int id) async {
    final response = await _requestHandler.getAnyNews(newsId: id);
    if (response.statusCode == 200) {
      _selectedNews = NewsModel.fromJson(response.data);
      notifyListeners();
    } else {
      throw HttpException("Impossible de récupérer l'actualité.");
    }
  }
}