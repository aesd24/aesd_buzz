import 'package:aesd/services/dio_service.dart';

class CinetpayRequest extends DioClient {
  verifyDonation({required String slug, required String transaction}) async {
    final client = await getApiClient();

    return client.get('/donations/$slug/verify?transaction=$transaction&ajax=true');
  }

  verifyStream({required String slug, required String transaction}) async {
    final client = await getApiClient();

    return client.get('/streams/$slug/verify?transaction=$transaction&ajax=true');
  }

  verifyJetonBuy({required String transaction}) async {
    final client = await getApiClient();

    return client.get('/buy/coins/verify?transaction=$transaction&ajax=true');
  }
}
