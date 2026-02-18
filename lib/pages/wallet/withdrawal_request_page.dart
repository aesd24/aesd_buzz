import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/services/withdrawal_service.dart';
import 'package:aesd/services/message.dart';

class WithdrawalRequestPage extends StatefulWidget {
  final String walletType; // 'church' ou 'pastor'
  final int walletId;
  final int currentBalance;

  const WithdrawalRequestPage({
    Key? key,
    required this.walletType,
    required this.walletId,
    required this.currentBalance,
  }) : super(key: key);

  @override
  State<WithdrawalRequestPage> createState() => _WithdrawalRequestPageState();
}

class _WithdrawalRequestPageState extends State<WithdrawalRequestPage> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _withdrawalService = WithdrawalService();
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _requestWithdrawal() async {
    final amount = int.tryParse(_amountController.text);
    final phone = _phoneController.text.trim();

    // Validations
    if (amount == null || amount < 1000) {
      MessageService.showErrorMessage('Montant minimum: 1000 XOF');
      return;
    }

    if (amount > widget.currentBalance) {
      MessageService.showErrorMessage('Solde insuffisant');
      return;
    }

    if (phone.isEmpty || phone.length < 10) {
      MessageService.showErrorMessage('Numéro de téléphone invalide');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await _withdrawalService.requestWithdrawal(
        walletType: widget.walletType,
        walletId: widget.walletId,
        amount: amount,
        phoneNumber: phone,
      );

      MessageService.showSuccessMessage('Demande de retrait envoyée avec succès');
      Navigator.pop(context, true); // Retour avec succès
    } catch (e) {
      MessageService.showErrorMessage('Erreur: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        title: Text(
          'Demande de retrait',
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
            // Solde disponible
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [appMainColor, appMainColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: appMainColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Solde disponible',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${widget.currentBalance} XOF',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Montant à retirer
            Text(
              'Montant à retirer',
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
                hintText: 'Minimum 1000 XOF',
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

            // Numéro de téléphone
            Text(
              'Numéro de téléphone',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: notifire.getMainText,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.poppins(color: notifire.getMainText),
              decoration: InputDecoration(
                hintText: 'Ex: 0707070707',
                hintStyle: GoogleFonts.poppins(color: notifire.getMaingey),
                prefixIcon: Icon(Icons.phone, color: appMainColor),
                filled: true,
                fillColor: notifire.getContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 20),

            // ⚠️ WARNING: Frais de retrait 13.5%
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Des frais de 13,5% seront appliqués sur le montant retiré',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Bouton de demande
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _requestWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
                child: _isProcessing
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Demander le retrait',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 20),

            // Info
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 10),
                      Text(
                        'Informations importantes',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Montant minimum: 1000 XOF\n'
                    '• Délai de traitement: 24-48h\n'
                    '• Le retrait sera envoyé par Mobile Money\n'
                    '• Vous recevrez une notification une fois traité',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange[800],
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
