import 'package:aesd/services/dio_service.dart';

class ServantRequest extends DioClient {
  all({dynamic queryParameters}) async {
    final client = await getApiClient();
    return client.get('/serviteurs');
  }

  one(int servantId) async {
    final client = await getApiClient();
    return await client.get('serviteurs/$servantId');
  }

  subscribe(int servantId, bool subscribe) async {
    final client = await getApiClient();
    return await client.post(
      '/subscribe_serviteurs/$servantId',
      data: {'subscriptionInput': subscribe == true ? 1 : 0},
    );
  }
}
