import 'package:aesd/models/user_model.dart';

class CommentModel {
  late int id;
  late String content;
  late UserModel owner;
  late DateTime date;
  late String? imageUrl;
  late int views;

  CommentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['comment'];
    owner = UserModel.fromJson(json['user']);
    date = DateTime.parse(json['created_at']);
    imageUrl = json['image'];
    views = json['nombre_vue'] ?? 0;
  }
}
