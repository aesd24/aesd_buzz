import 'package:aesd/services/dio_service.dart';

class ForumRequest extends DioClient {
  getAll({dynamic queryParameters}) async {
    final client = await getApiClient();
    return client.get('/sujets');
  }

  getAny({required int newsId}) async {
    final client = await getApiClient();
    return client.get('/sujet/$newsId');
  }

  makeComment({required int subjectId, required String comment}) async {
    final client = await getApiClient();

    return client.post(
      'sujet/commentaire/$subjectId',
      data: {'comment': comment}
    );
  }

  likeSubject({required int subjectId}) async {
    final client = await getApiClient();
    return client.post('sujet/like/$subjectId');
  }
}
