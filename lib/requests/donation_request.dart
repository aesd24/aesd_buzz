import 'package:aesd/services/dio_service.dart';

class DonationRequest extends DioClient {
  all({dynamic queryParameters}) async {
    final client = await getApiClient();

    return client.get('/donations', queryParameters: queryParameters);
  }
}
