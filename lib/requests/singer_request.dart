import 'package:aesd/services/dio_service.dart';

class SingerRequest extends DioClient {
  all({dynamic queryParameters}) async {
    final client = await getApiClient();

    return client.get('/chantres');
  }
}
