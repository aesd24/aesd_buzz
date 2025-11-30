import 'package:aesd/services/dio_service.dart';

class UserRequest extends DioClient {
  Future getUser(int userId) async {
    final client = await getApiClient();
    return await client.get('user/$userId');
  }
}
