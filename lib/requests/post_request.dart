import 'package:aesd/services/dio_service.dart';

class PostRequest extends DioClient {
  final String baseRoute = "posts";
  
  Future all() async {
    final client = await getApiClient();
    return client.get(baseRoute);
  }

  Future detail(int id) async {
    final client = await getApiClient();
    return client.get('$baseRoute/$id');
  }

  Future create({required Object data}) async {
    final client = await getApiClient();
    return client.post(baseRoute, data: data);
  }

  Future likePost(int postId) async {
    final client = await getApiClient();
    return client.post('$baseRoute/like/$postId');
  }

  Future makeComment(int postId, String comment) async {
    final client = await getApiClient();
    return client.post('$baseRoute/comments/$postId', data: {
      'comment': comment
    });
  }

  Future getUserPosts(int userId) async {
    final client = await getApiClient();
    return client.get('$baseRoute/servants/$userId/posts');
  }
}
