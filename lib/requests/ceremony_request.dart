import 'package:aesd/services/dio_service.dart';
import 'package:dio/dio.dart';

class CeremonyRequest extends DioClient {
  Future create(FormData formData) async {
    var client = await getApiClient(
      contentType: "multipart/form-data; boundary=${formData.boundary}"
    );
    return await client.post('/ceremonies', data: formData);
  }

  Future update(int id, FormData formData) async {
    var client = await getApiClient();
    return await client.post('/ceremonies/$id', data: formData);
  }

  Future delete(int churchId) async {
    var client = await getApiClient();
    return await client.delete('/ceremonies/$churchId');
  }

  Future getAll(int churchId) async {
    var client = await getApiClient();
    return await client.get('eglise/ceremonies/$churchId');
  }

  Future detail(int id) async {
    var client = await getApiClient();
    return await client.get('ceremonies/$id');
  }
}