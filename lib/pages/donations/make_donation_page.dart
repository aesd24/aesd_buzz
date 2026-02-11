import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cinetpay/cinetpay.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/services/donation_service.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MakeDonationPage extends StatefulWidget {
  final String recipientType; // 'church' ou 'pastor'
  final int recipientId;
  final String recipientName;
  final String? recipientPhoto;

  const MakeDonationPage({
    Key? key,
    required this.recipientType,
    required this.recipientId,
    required this.recipientName,
    this.recipientPhoto,
  }) : super(key: key);

  @override
  State<MakeDonationPage> createState() => _MakeDonationPageState();
}

class _MakeDonationPageState extends State<MakeDonationPage> {
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  final _donationService = DonationService();
  bool _isProcessing = false;

  // Configuration  // Getters pour les variables d'environnement CinetPay
  String get cinetpayApiKey => dotenv.env['CINETPAY_API_KEY'] ?? '';
  
  int get cinetpaySiteId {
    final siteIdStr = dotenv.env['CINETPAY_SITE_ID'] ?? '0';
    return int.tryParse(siteIdStr) ?? 0;
  }
  
  String get cinetpayNotifyUrl => dotenv.env['CINETPAY_NOTIFY_URL'] ?? '';

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _makeDonation() async {
    final amount = int.tryParse(_amountController.text);
    
    // Validation
    if (amount == null || amount < 100) {
      MessageService.showErrorMessage('Montant minimum: 100 XOF');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Générer un transaction_id unique localement
      // Format: DON_userId_timestamp
      final transactionId = 'DON_${widget.recipientId}_${DateTime.now().millisecondsSinceEpoch}';
      
      print('💰 [DONATION] ========================================');
      print('💰 [DONATION] Préparation du paiement CinetPay');
      print('💰 [DONATION] - Transaction ID: $transactionId');
      print('💰 [DONATION] - Montant: $amount XOF');
      print('💰 [DONATION] - Destinataire: ${widget.recipientName}');
      print('💰 [DONATION] - Type: ${widget.recipientType}');
      print('💰 [DONATION] ========================================');
      
      // TODO: Quand le backend sera accessible, décommenter ceci:
      // final initResponse = await _donationService.initDonation(
      //   recipientId: widget.recipientId,
      //   recipientType: widget.recipientType,
      //   amount: amount,
      //   message: _messageController.text.isEmpty ? null : _messageController.text,
      // );
      // final transactionId = initResponse['transaction_id'];

      // 2. Lancer le widget CinetPay
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CinetPayCheckout(
            title: 'Don à ${widget.recipientName}',
            titleStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: appMainColor,
            ),
            titleBackgroundColor: Colors.white,
            configData: {
              'apikey': cinetpayApiKey,
              'site_id': cinetpaySiteId,
              'notify_url': cinetpayNotifyUrl,
            },
            paymentData: {
              'transaction_id': transactionId,
              'amount': amount,
              'currency': 'XOF',
              'channels': 'ALL',
              'description': 'Don à ${widget.recipientName}',
              'customer_name': 'Donateur',
              'customer_surname': 'AESD',
              'customer_email': 'contact@eglisesetserviteursdedieu.com',
              'customer_phone_number': '0000000000',
              'customer_address': 'Côte d\'Ivoire',
              'customer_city': 'Abidjan',
              'customer_country': 'CI',
              'customer_state': 'CI',
              'customer_zip_code': '00000',
              'metadata': jsonEncode({
                'recipient_type': widget.recipientType,
                'recipient_id': widget.recipientId.toString(),
                'recipient_name': widget.recipientName,
                'message': _messageController.text.isEmpty ? '' : _messageController.text,
              }),
            },
            waitResponse: (response) {
              setState(() => _isProcessing = false);
              
              if (response['status'] == 'ACCEPTED') {
                _showSuccessDialog(response);
              } else {
                _showErrorDialog('Paiement refusé');
              }
            },
            onError: (error) {
              setState(() => _isProcessing = false);
              _showErrorDialog(error['description'] ?? 'Erreur de paiement');
            },
          ),
        ),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      MessageService.showErrorMessage('Erreur: ${e.toString()}');
    }
  }

  void _showSuccessDialog(Map response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text(
              'Don réussi !',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Text(
          'Votre don de ${response['amount']} XOF a été envoyé à ${widget.recipientName}.\n\n'
          'Que Dieu vous bénisse pour votre générosité ! 🙏',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer dialog
              Navigator.of(context).pop(); // Retour page précédente
            },
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: appMainColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('Erreur', style: GoogleFonts.poppins(color: Colors.red)),
          ],
        ),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: GoogleFonts.poppins(color: appMainColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        title: Text(
          'Faire un don',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: appMainColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bénéficiaire
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: notifire.getContainer,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: appMainColor,
                    backgroundImage: widget.recipientPhoto != null
                        ? NetworkImage(widget.recipientPhoto!)
                        : null,
                    child: widget.recipientPhoto == null
                        ? Icon(
                            widget.recipientType == 'church'
                                ? Icons.church
                                : Icons.person,
                            color: Colors.white,
                            size: 30,
                          )
                        : null,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.recipientName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: notifire.getMainText,
                          ),
                        ),
                        Text(
                          widget.recipientType == 'church' ? 'Église' : 'Serviteur de Dieu',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: notifire.getMaingey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Montant
            Text(
              'Montant du don',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: notifire.getMainText,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(color: notifire.getMainText),
              decoration: InputDecoration(
                hintText: 'Minimum 100 XOF',
                hintStyle: GoogleFonts.poppins(color: notifire.getMaingey),
                prefixIcon: Icon(Icons.money, color: appMainColor),
                suffixText: 'XOF',
                filled: true,
                fillColor: notifire.getContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Message optionnel
            Text(
              'Message (optionnel)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: notifire.getMainText,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 3,
              style: GoogleFonts.poppins(color: notifire.getMainText),
              decoration: InputDecoration(
                hintText: 'Que Dieu vous bénisse...',
                hintStyle: GoogleFonts.poppins(color: notifire.getMaingey),
                filled: true,
                fillColor: notifire.getContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Bouton de don
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _makeDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: _isProcessing
                    ? CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Faire un don',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Info
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Paiement sécurisé via Orange Money, MTN Money ou Wave',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
