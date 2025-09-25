import 'package:aesd/services/dio_service.dart';

class ForumRequest extends DioClient {
  final String baseRoute = 'sujets';
  getAll({dynamic queryParameters}) async {
    final client = await getApiClient();
    return client.get(baseRoute);
  }

  getAny({required int newsId}) async {
    final client = await getApiClient();
    return client.get('$baseRoute/$newsId');
  }

  makeComment({required int subjectId, required String comment}) async {
    final client = await getApiClient();

    return client.post(
      '$baseRoute/$subjectId/commentaire',
      data: {'comment': comment}
    );
  }

  likeSubject({required int subjectId}) async {
    final client = await getApiClient();
    return client.post('$baseRoute/$subjectId/like');
  }
}
