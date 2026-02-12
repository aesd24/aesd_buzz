import 'package:aesd/services/dio_service.dart';

/// Service pour gérer les wallets de donations des églises et pasteurs
/// 
/// Ce service gère les opérations liées aux dons reçus par les églises
/// et pasteurs, incluant la récupération du solde et l'historique.
class DonationWalletService extends DioClient {
  
  /// Récupérer le solde du wallet de donations
  /// 
  /// Paramètres:
  /// - [walletType]: 'church' ou 'pastor'
  /// - [walletId]: ID de l'église ou du pasteur
  /// 
  /// Retourne le solde actuel et les statistiques
  Future<Map<String, dynamic>> getBalance({
    required String walletType,
    required int walletId,
  }) async {
    final client = await getApiClient();
    
    final response = await client.get(
      '/wallets/balance',
      queryParameters: {
        'recipient_type': walletType,
        'recipient_id': walletId,
      },
    );
    
    return response.data;
  }
  
  /// Récupérer l'historique des dons reçus
  /// 
  /// Paramètres:
  /// - [recipientType]: 'church' ou 'pastor'
  /// - [recipientId]: ID du bénéficiaire
  /// - [page]: Numéro de page (défaut: 1)
  /// 
  /// Retourne la liste des dons reçus
  Future<Map<String, dynamic>> getReceivedDonations({
    required String recipientType,
    required int recipientId,
    int page = 1,
  }) async {
    final client = await getApiClient();
    
    final response = await client.get(
      '/donations/received',
      queryParameters: {
        'recipient_type': recipientType,
        'recipient_id': recipientId,
        'page': page,
      },
    );
    
    return response.data;
  }
}
