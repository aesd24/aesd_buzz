import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageAuthTokenSession {
  final String type;
  final String token;
  static const _storage = FlutterSecureStorage();

  StorageAuthTokenSession({required this.type, required this.token});

  static Future<StorageAuthTokenSession> getFormSecureStorage() async {
    List<dynamic> tokenInfo = await Future.wait([
      _storage.read(key: 'auth_token_type'),
      _storage.read(key: 'auth_token'),
    ]);

    /*if (tokenInfo == null) {
      throw Exception("Missing token info");
    }*/

    return StorageAuthTokenSession(type: tokenInfo[0] ?? '', token: tokenInfo[1] ?? '');
  }

  Future<StorageAuthTokenSession> storeOnSecureStorage(
      {required String type, required String token}) async {
    await Future.wait([
      _storage.write(key: 'auth_token', value: token),
      _storage.write(key: 'auth_token_type', value: type)
    ]);

    return StorageAuthTokenSession(type: type, token: token);
  }

  Future<void> deleteOnSecureStorage() async {
    await Future.wait([
      _storage.delete(key: 'auth_token'),
      _storage.delete(key: 'auth_token_type')
    ]);
  }
}
