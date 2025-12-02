import 'package:aesd/services/dio_service.dart';

class ServantRequest extends DioClient {
  final String baseRoute = "serviteurs";
  Future all({dynamic queryParameters}) async {
    final client = await getApiClient();
    return client.get(baseRoute);
  }

  Future one(int servantId) async {
    final client = await getApiClient();
    return await client.get('$baseRoute/$servantId');
  }

  Future subscribe(int servantId, bool subscribe) async {
    final client = await getApiClient();
    return await client.post(
      '$baseRoute/subscribe/$servantId',
      data: {'subscriptionInput': subscribe == true ? 1 : 0},
    );
  }

  Future stats() async {
    final client = await getApiClient();
    return await client.get('serviteur/stats-abonnements');
  }
}
