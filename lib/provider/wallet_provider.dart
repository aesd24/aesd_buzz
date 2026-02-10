import 'package:flutter/material.dart';
import 'package:aesd/services/wallet_service.dart';

/// Provider pour gérer l'état du wallet
/// 
/// Ce provider gère le solde, les transactions et les opérations
/// de paiement du wallet de l'utilisateur
class WalletProvider extends ChangeNotifier {
  final WalletService _walletService = WalletService();
  
  // État
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  double get balance => _balance;
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Récupérer le solde du wallet
  Future<void> fetchBalance() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _walletService.getBalance();
      
      if (response['success'] == true) {
        _balance = (response['data']['balance'] as num).toDouble();
      } else {
        _error = response['message'] ?? 'Erreur lors de la récupération du solde';
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur fetchBalance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Initialiser un dépôt
  /// 
  /// Retourne l'URL de paiement CinetPay ou null en cas d'erreur
  Future<String?> initDeposit({
    required int amount,
    required String paymentMethod,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _walletService.initDeposit(
        amount: amount,
        paymentMethod: paymentMethod,
      );
      
      if (response['success'] == true) {
        return response['data']['payment_url'];
      } else {
        _error = response['message'] ?? 'Erreur lors de l\'initialisation du dépôt';
        return null;
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur initDeposit: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Vérifier un dépôt et mettre à jour le solde
  Future<bool> verifyDeposit(String transactionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _walletService.verifyDeposit(
        transactionId: transactionId,
      );
      
      if (response['success'] == true && response['data']['status'] == 'completed') {
        _balance = (response['data']['new_balance'] as num).toDouble();
        return true;
      } else {
        _error = 'Le paiement n\'a pas encore été confirmé';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur verifyDeposit: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Initialiser un retrait
  Future<bool> initWithdraw({
    required int amount,
    required String paymentMethod,
    required String phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _walletService.initWithdraw(
        amount: amount,
        paymentMethod: paymentMethod,
        phoneNumber: phoneNumber,
      );
      
      if (response['success'] == true) {
        // Mettre à jour le solde localement
        final totalDeducted = (response['data']['total_deducted'] as num).toDouble();
        _balance -= totalDeducted;
        return true;
      } else {
        _error = response['message'] ?? 'Erreur lors de l\'initialisation du retrait';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur initWithdraw: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Envoyer de l'argent à un autre utilisateur
  Future<bool> sendMoney({
    required int recipientId,
    required int amount,
    String? message,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _walletService.sendMoney(
        recipientId: recipientId,
        amount: amount,
        message: message,
      );
      
      if (response['success'] == true) {
        _balance = (response['data']['sender_new_balance'] as num).toDouble();
        return true;
      } else {
        _error = response['message'] ?? 'Erreur lors de l\'envoi';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur sendMoney: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Récupérer l'historique des transactions
  Future<void> fetchTransactions({
    int page = 1,
    String? type,
    String? status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _walletService.getTransactions(
        page: page,
        type: type,
        status: status,
      );
      
      if (response['success'] == true) {
        _transactions = List<Map<String, dynamic>>.from(
          response['data']['transactions'] ?? []
        );
      } else {
        _error = response['message'] ?? 'Erreur lors de la récupération des transactions';
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur fetchTransactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Rafraîchir toutes les données du wallet
  Future<void> refresh() async {
    await Future.wait([
      fetchBalance(),
      fetchTransactions(),
    ]);
  }
}
