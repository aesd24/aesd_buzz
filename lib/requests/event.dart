import 'package:aesd/services/dio_service.dart';
import 'package:dio/dio.dart';

class EventRequest extends DioClient {
  Future create(FormData formData) async {
    var client = await getApiClient(
      contentType: "multipart/form-data; boundary=${formData.boundary}"
    );
    return await client.post('/events', data: formData);
  }

  Future update(int id, FormData formData) async {
    var client = await getApiClient();
    return await client.post('/events/$id', data: formData);
  }

  Future delete(int id) async {
    var client = await getApiClient();
    return await client.delete('/events/$id');
  }

  Future getEvents(int churchId) async {
    var client = await getApiClient();
    return await client.get('events/$churchId');
  }

  Future getEventDetail(int id) async {
    var client = await getApiClient();
    return await client.get('show/events/$id');
  }
}