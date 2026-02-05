import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Provider pour gérer les paiements CinetPay
/// 
/// Ce provider gère l'initialisation et le traitement des paiements
/// via l'API CinetPay pour les donations, achats de jetons, etc.
class CinetPay extends ChangeNotifier {
  
  // Configuration CinetPay (à remplacer par vos vraies clés)
  static const String apiKey = 'YOUR_CINETPAY_API_KEY';
  static const String siteId = 'YOUR_CINETPAY_SITE_ID';
  static const String apiUrl = 'https://api-checkout.cinetpay.com/v2/payment';
  
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  
  /// Initier un paiement CinetPay
  /// 
  /// Paramètres:
  /// - [context]: BuildContext pour la navigation
  /// - [amount]: Montant du paiement en XOF
  /// - [description]: Description du paiement
  /// - [notifyUrl]: URL de notification webhook
  /// - [returnUrl]: URL de retour après paiement
  /// 
  /// Retourne une réponse HTTP avec l'URL de paiement
  Future<http.Response> makePayment(
    BuildContext context, {
    required int amount,
    required String description,
    required String notifyUrl,
    required String returnUrl,
  }) async {
    try {
      _isProcessing = true;
      notifyListeners();
      
      // Générer un ID de transaction unique
      final transactionId = 'AESD_${DateTime.now().millisecondsSinceEpoch}';
      
      // Préparer les données du paiement
      final paymentData = {
        'apikey': apiKey,
        'site_id': siteId,
        'transaction_id': transactionId,
        'amount': amount,
        'currency': 'XOF',
        'description': description,
        'notify_url': notifyUrl,
        'return_url': returnUrl,
        'channels': 'ALL', // Tous les moyens de paiement disponibles
        'metadata': {
          'app': 'AESD Buzz',
          'timestamp': DateTime.now().toIso8601String(),
        },
      };
      
      // Appeler l'API CinetPay
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(paymentData),
      );
      
      return response;
      
    } catch (e) {
      print('Erreur lors de l\'initialisation du paiement: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// Vérifier le statut d'un paiement
  /// 
  /// Paramètres:
  /// - [transactionId]: ID de la transaction à vérifier
  /// 
  /// Retourne true si le paiement est réussi, false sinon
  Future<bool> verifyPayment(String transactionId) async {
    try {
      final verifyUrl = 'https://api-checkout.cinetpay.com/v2/payment/check';
      
      final response = await http.post(
        Uri.parse(verifyUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'apikey': apiKey,
          'site_id': siteId,
          'transaction_id': transactionId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['code'] == '00'; // Code 00 = paiement réussi
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de la vérification du paiement: $e');
      return false;
    }
  }
}
