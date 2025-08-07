import 'package:aesd/services/dio_service.dart';

class TestimonyRequest extends DioClient {
  all() async {
    final client = await getApiClient();
    return client.get('temoignages');
  }

  create(Object data) async {
    final client = await getApiClient();
    return client.post('temoignages', data: data);
  }

  one(int id) async {
    final client = await getApiClient();
    return client.get('temoignages/$id');
  }

  forUser() async {
    final client = await getApiClient();
    return client.get('temoignages/user');
  }

  remove(int id) async {
    final client = await getApiClient();
    return client.delete('temoignages/$id');
  }
}