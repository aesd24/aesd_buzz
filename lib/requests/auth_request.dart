import 'package:dio/dio.dart';
import 'package:aesd/services/dio_service.dart';

class AuthRequest extends DioClient {
  
  Future login({required Object data}) async {
    final client = await getApiClient();
    client.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
    ));
    return client.post('login', data: data);
  }

  Future register({required Object data}) async {
    final client = await getApiClient();
    return await client.post('register', data: data);
  }

  Future logout() async {
    final client = await getApiClient();
    return client.post('logout');
  }

  Future getUserData() async {
    final client = await getApiClient();
    return await client.get('user_auth_infos');
  }

  Future forgotPassword({required String user_info}) async {
    final client = await getApiClient();
    return await client.post('password/forgot', data: {'user_info': user_info});
  }

  Future changePassword(FormData formdata) async {
    final client = await getApiClient();
    return await client.post('password/reset', data: formdata);
  }

  Future verifyOtp({required String code}) async {
    final client = await getApiClient();
    return client.post('verify-Otp', data: {'otp_code': code});
  }

  Future modifyInformation(FormData formData) async {
    final client = await getApiClient();
    return await client.post('update-profile', data: formData);
  }

  Future retryCertificationRequest(FormData formData) async {
    final client = await getApiClient();
    return await client.post('serviteurs/resubmit-documents', data: formData);
  }
}
