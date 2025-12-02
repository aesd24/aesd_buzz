import 'package:aesd/services/dio_service.dart';
import 'package:dio/dio.dart';

class EventRequest extends DioClient {

  final String baseRoute = "events";

  Future create(FormData formData) async {
    var client = await getApiClient(
      contentType: "multipart/form-data; boundary=${formData.boundary}"
    );
    return await client.post(baseRoute, data: formData);
  }

  Future update(int id, FormData formData) async {
    var client = await getApiClient();
    return await client.post('$baseRoute/$id', data: formData);
  }

  Future delete(int id) async {
    var client = await getApiClient();
    return await client.delete('$baseRoute/$id');
  }

  Future getEvents(int churchId) async {
    var client = await getApiClient();
    return await client.get('$baseRoute/$churchId');
  }

  Future getEventDetail(int id) async {
    var client = await getApiClient();
    return await client.get('$baseRoute/show/$id');
  }
}