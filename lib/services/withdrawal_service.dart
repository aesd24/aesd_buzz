import 'package:dio/dio.dart';
import 'package:aesd/services/dio_service.dart';
import 'package:aesd/models/withdrawal_model.dart';

class WithdrawalService {
  final _dioClient = DioClient();
  
  Future<Dio> getApiClient() async {
    return await _dioClient.getApiClient();
  }

  /// Demander un retrait
  Future<Map<String, dynamic>> requestWithdrawal({
    required String walletType,
    required int walletId,
    required int amount,
    required String phoneNumber,
  }) async {
    final client = await getApiClient();
    
    final response = await client.post('/withdrawals/request', data: {
      'wallet_type': walletType,
      'wallet_id': walletId,
      'amount': amount,
      'phone_number': phoneNumber,
    });
    
    return response.data;
  }

  /// Récupérer l'historique des demandes de retrait
  Future<List<WithdrawalModel>> getMyWithdrawals() async {
    final client = await getApiClient();
    
    final response = await client.get('/withdrawals/history');
    
    final List<dynamic> data = response.data['data'];
    return data.map((json) => WithdrawalModel.fromJson(json)).toList();
  }

  /// Récupérer les demandes en attente (admin)
  Future<List<WithdrawalModel>> getPendingWithdrawals() async {
    final client = await getApiClient();
    
    final response = await client.get('/withdrawals/pending');
    
    final List<dynamic> data = response.data['data'];
    return data.map((json) => WithdrawalModel.fromJson(json)).toList();
  }
}
