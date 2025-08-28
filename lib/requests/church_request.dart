import 'package:aesd/services/dio_service.dart';

class ChurchRequest extends DioClient {

  Future userChurches() async {
    final client = await getApiClient();
    return await client.get('/churches');
  }

  Future all({required int page}) async {
    final client = await getApiClient();
    return client.get('user_church', queryParameters: {"page": page});
  }

  Future one(int id) async {
    final client = await getApiClient();
    return client.get("churches/$id");
  }

  Future create(Object data) async {
    final client = await getApiClient(contentType: "Multipart/form-data");
    return await client.post("churches", data: data);
  }

  Future update(Object data, {required int churchId}) async {
    final client = await getApiClient(contentType: "Multipart/form-data");
    return await client.post("churches/$churchId", data: data);
  }

  Future subscribe(int id, {required bool willSubscribe}) async {
    final client = await getApiClient();
    return client.post("churches_subscribe/$id", data: {
      'subscriptionInput': willSubscribe ? 1 : 0
    });
  }
}
