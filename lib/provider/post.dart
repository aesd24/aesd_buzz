import 'dart:io';
import 'package:aesd/models/comment.dart';
import 'package:aesd/models/post_model.dart';
import 'package:aesd/requests/post_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PostProvider extends ChangeNotifier {
  final PostRequest _request = PostRequest();
  PostPaginator? _paginator;

  PostModel? _selectedPost;
  PostModel? get selectedPost => _selectedPost;

  final List<PostModel> _posts = [];
  final List<CommentModel> _postComments = [];

  List<PostModel> get posts => _posts;
  List<CommentModel> get comments => _postComments;

  Future create(FormData data) async {
    var response = await _request.create(data: data);
    print(response);
    if (response.statusCode != 201) {
      throw HttpException(response.data['message']);
    }
  }

  Future likePost(int id) async {
    final response = await _request.likePost(id);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw HttpException(response.data['message']);
    }
  }

  Future getPosts() async {
    var response = await _request.all();
    print(response.data);
    _paginator = PostPaginator.fromJson(response.data);
    if (response.statusCode == 200) {
      _posts.clear();
      _posts.addAll(_paginator!.posts);
    } else {
      throw HttpException(response.data['message']);
    }
    _paginator!.currentPage += 1;
    notifyListeners();
  }

  Future postDetail(int postId) async {
    final response = await _request.detail(postId);
    print(response.data['post']);
    if (response.statusCode == 200) {
      _selectedPost = PostModel.fromJson(response.data['post']);
      _postComments.clear();
      for (var comment in response.data['Comments']){
        _postComments.add(CommentModel.fromJson(comment));
      }
    } else {
      throw HttpException(response.data['message']);
    }
    notifyListeners();
  }

  Future makeComment(int postId, String comment) async {
    final response = await _request.makeComment(postId, comment);
    print(response);
    if (response.statusCode != 200) {
      throw HttpException(response.data['message']);
    }
  }

  Future getUserPosts(int userId) async {
    final response = await _request.getUserPosts(userId);
    print(response);
    if (response.statusCode == 200) {
      final List<PostModel> results = [];
      for (var post in response.data['posts']) {
        results.add(PostModel.fromJson(post));
      }
      notifyListeners();
      return results;
    } else {
      throw HttpException("Impossible de charger les posts");
    }
  }
}
