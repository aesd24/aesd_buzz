import 'package:aesd/services/dio_service.dart';
import 'package:dio/src/response.dart';

class QuizRequest extends DioClient {
  final String baseRoute = "quiz";

  Future getAll() async {
    final client = await getApiClient();
    return client.get(baseRoute);
  }

  Future getAny(int quizId) async {
    final client = await getApiClient();
    return client.get('$baseRoute/$quizId');
  }

  Future sendResponses({required int quizId, required Object results}) async {
    final client = await getApiClient();
    return client.post('$baseRoute/reponses/$quizId', data: results);
  }

  Future correctAnswers(int quizId) async {
    final client = await getApiClient();
    return client.get(
      '$baseRoute/$quizId/bonnes-reponses',
    );
  }

  Future monthRanking() async {
    final client = await getApiClient();
    return client.get(
      '$baseRoute/classement-general-mensuel',
    );
  }

  Future quizRanking(int quizId) async {
    final client = await getApiClient();
    return client.get(
      '$baseRoute/$quizId/classement',
    );
  }
}
