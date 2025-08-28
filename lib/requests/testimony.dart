import 'package:aesd/services/dio_service.dart';

class TestimonyRequest extends DioClient {
  Future all() async {
    final client = await getApiClient();
    return client.get('temoignages');
  }

  Future create(Object data) async {
    final client = await getApiClient();
    return client.post('temoignages', data: data);
  }

  Future one(int id) async {
    final client = await getApiClient();
    return client.get('temoignages/$id');
  }

  Future forUser() async {
    final client = await getApiClient();
    return client.get('temoignages/user');
  }

  Future remove(int id) async {
    final client = await getApiClient();
    return client.delete('temoignages/$id');
  }
}