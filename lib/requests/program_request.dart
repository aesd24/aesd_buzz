import 'package:aesd/services/dio_service.dart';

class ProgramRequest extends DioClient {
  final String baseRoute = "programmes";

  Future getAll(int churchId) async {
    final client = await getApiClient();
    return client.get('$baseRoute/church/$churchId');
  }

  Future getOne(int id) async {
    final client = await getApiClient();
    return client.get('$baseRoute/$id');
  }

  Future create(Object data) async {
    final client = await getApiClient(contentType: "Multipart/form-data");
    return await client.post(baseRoute, data: data);
  }

  Future update(int id, {required Object data}) async {
    final client = await getApiClient(contentType: "Multipart/form-data");
    return await client.post('$baseRoute/$id', data: data);
  }

  Future deleteAny(int id) async {
    final client = await getApiClient();
    return await client.delete('$baseRoute/church/$baseRoute/$id');
  }

  Future deleteAllOfDay(String day, {required int churchId}) async {
    final client = await getApiClient();
    return await client.delete(
      '$baseRoute/church/$churchId/$baseRoute/day/$day',
    );
  }
}
