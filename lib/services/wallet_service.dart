import 'package:aesd/services/dio_service.dart';

/// Service pour gérer les opérations du wallet
/// 
/// Ce service gère toutes les interactions avec l'API backend
/// pour les opérations de wallet (dépôt, retrait, envoi, solde, transactions)
class WalletService extends DioClient {
  
  /// Récupérer le solde du wallet
  /// 
  /// Retourne le solde actuel de l'utilisateur connecté
  Future<Map<String, dynamic>> getBalance() async {
    final client = await getApiClient();
    final response = await client.get('/wallet/balance');
    return response.data;
  }
  
  /// Initialiser un dépôt
  /// 
  /// Paramètres:
  /// - [amount]: Montant à déposer en XOF
  /// - [paymentMethod]: Méthode de paiement (orange_money, mtn_money, wave)
  /// - [returnUrl]: URL de retour après paiement (optionnel)
  /// - [cancelUrl]: URL d'annulation (optionnel)
  /// 
  /// Retourne l'URL de paiement CinetPay et les détails de la transaction
  Future<Map<String, dynamic>> initDeposit({
    required int amount,
    required String paymentMethod,
    String? returnUrl,
    String? cancelUrl,
  }) async {
    final client = await getApiClient();
    
    final response = await client.post('/wallet/deposit/init', data: {
      'amount': amount,
      'payment_method': paymentMethod,
      'return_url': returnUrl ?? 'aesd://wallet/deposit/success',
      'cancel_url': cancelUrl ?? 'aesd://wallet/deposit/cancel',
    });
    
    return response.data;
  }
  
  /// Vérifier le statut d'un dépôt
  /// 
  /// Paramètres:
  /// - [transactionId]: ID de la transaction à vérifier
  /// 
  /// Retourne le statut actuel de la transaction
  Future<Map<String, dynamic>> verifyDeposit({
    required String transactionId,
  }) async {
    final client = await getApiClient();
    
    final response = await client.post('/wallet/deposit/verify', data: {
      'transaction_id': transactionId,
    });
    
    return response.data;
  }
  
  /// Initialiser un retrait
  /// 
  /// Paramètres:
  /// - [amount]: Montant à retirer en XOF
  /// - [paymentMethod]: Méthode de paiement (orange_money, mtn_money, wave)
  /// - [phoneNumber]: Numéro de téléphone pour recevoir l'argent
  /// 
  /// Retourne les détails de la transaction de retrait
  Future<Map<String, dynamic>> initWithdraw({
    required int amount,
    required String paymentMethod,
    required String phoneNumber,
  }) async {
    final client = await getApiClient();
    
    final response = await client.post('/wallet/withdraw/init', data: {
      'amount': amount,
      'payment_method': paymentMethod,
      'phone_number': phoneNumber,
    });
    
    return response.data;
  }
  
  /// Envoyer de l'argent à un autre utilisateur
  /// 
  /// Paramètres:
  /// - [recipientId]: ID de l'utilisateur destinataire
  /// - [amount]: Montant à envoyer en XOF
  /// - [message]: Message optionnel
  /// 
  /// Retourne les détails de la transaction
  Future<Map<String, dynamic>> sendMoney({
    required int recipientId,
    required int amount,
    String? message,
  }) async {
    final client = await getApiClient();
    
    final response = await client.post('/wallet/send', data: {
      'recipient_id': recipientId,
      'amount': amount,
      if (message != null) 'message': message,
    });
    
    return response.data;
  }
  
  /// Récupérer l'historique des transactions
  /// 
  /// Paramètres:
  /// - [page]: Numéro de page (défaut: 1)
  /// - [perPage]: Nombre d'éléments par page (défaut: 20)
  /// - [type]: Filtrer par type (deposit, withdraw, transfer)
  /// - [status]: Filtrer par statut (pending, completed, failed)
  /// 
  /// Retourne la liste paginée des transactions
  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int perPage = 20,
    String? type,
    String? status,
  }) async {
    final client = await getApiClient();
    
    final queryParameters = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (type != null) queryParameters['type'] = type;
    if (status != null) queryParameters['status'] = status;
    
    final response = await client.get('/wallet/transactions', queryParameters: queryParameters);
    return response.data;
  }
}
