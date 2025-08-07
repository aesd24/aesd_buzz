import 'package:aesd/services/dio_service.dart';

class UserRequest extends DioClient {
  getUserData() async {
    final client = await getApiClient();
    return await client.get('user_auth_infos');
  }
}
