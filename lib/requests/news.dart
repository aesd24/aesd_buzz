import 'package:aesd/services/dio_service.dart';

class NewsRequest extends DioClient {
  final String baseRoute = 'actualites';

  Future getAllNews({required int currentPage, required int limit}) async {
    var client = await getApiClient();
    return await client.get(baseRoute);
  }

  Future getAnyNews({required int newsId}) async {
    var client = await getApiClient();
    return await client.get('$baseRoute/$newsId');
  }
}