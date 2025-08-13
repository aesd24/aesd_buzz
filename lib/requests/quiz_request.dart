import 'package:aesd/services/dio_service.dart';

class QuizRequest extends DioClient {
  getAll() async {
    final client = await getApiClient();
    return client.get('/quiz');
  }

  getAny(int quizId) async {
    final client = await getApiClient();
    return client.get('/quiz/$quizId');
  }

  show(String slug) async {
    final client = await getApiClient();
    return client.get('/quizzes/$slug/show');
  }

  canPlay(String slug) async {
    final client = await getApiClient();
    return client.get('/quizzes/$slug/can-play');
  }

  sendResponses({required int quizId, required Object results}) async {
    final client = await getApiClient();
    return client.post('/quiz/reponses/$quizId', data: results);
  }

  participants({required String slug, required dynamic queryParameters}) async {
    final client = await getApiClient();
    return client.get('/quizzes/$slug/participants', queryParameters: queryParameters);
  }
}
