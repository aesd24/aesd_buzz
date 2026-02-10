import 'package:dio/dio.dart';
import 'package:aesd/services/dio_service.dart';
import 'package:aesd/models/donation_transaction_model.dart';

class DonationService {
  final _dioClient = DioClient();
  
  Future<Dio> getApiClient() async {
    return await _dioClient.getApiClient();
  }

  /// Préparer une transaction de don
  Future<Map<String, dynamic>> initDonation({
    required int recipientId,
    required String recipientType,
    required int amount,
    String? message,
  }) async {
    final client = await getApiClient();
    
    final response = await client.post('/donations/init', data: {
      'recipient_id': recipientId,
      'recipient_type': recipientType,
      'amount': amount,
      'message': message,
    });
    
    return response.data;
  }

  /// Récupérer l'historique des dons effectués
  Future<List<DonationTransactionModel>> getMyDonations() async {
    final client = await getApiClient();
    
    final response = await client.get('/donations/history');
    
    final List<dynamic> data = response.data['data'];
    return data.map((json) => DonationTransactionModel.fromJson(json)).toList();
  }

  /// Récupérer les dons reçus (pour église/pasteur)
  Future<Map<String, dynamic>> getReceivedDonations({
    required int recipientId,
    required String recipientType,
  }) async {
    final client = await getApiClient();
    
    final response = await client.get(
      '/donations/received',
      queryParameters: {
        'recipient_id': recipientId,
        'recipient_type': recipientType,
      },
    );
    
    return response.data;
  }

  /// Récupérer le solde du wallet
  Future<int> getWalletBalance({
    required int recipientId,
    required String recipientType,
  }) async {
    final client = await getApiClient();
    
    final response = await client.get(
      '/wallets/balance',
      queryParameters: {
        'recipient_id': recipientId,
        'recipient_type': recipientType,
      },
    );
    
    return response.data['balance'];
  }
}
