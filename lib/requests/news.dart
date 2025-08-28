import 'package:aesd/services/dio_service.dart';

class NewsRequest extends DioClient {
  Future getAllNews({required int currentPage, required int limit}) async {
    var client = await getApiClient();
    return await client.get('actualités');
  }

  Future getAnyNews({required int newsId}) async {
    var client = await getApiClient();
    return await client.get('actualité/${newsId}');
  }
}