import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/services/donation_wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  bool _isLoading = true;
  List<dynamic> _donations = [];
  List<dynamic> _filteredDonations = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    final user = Provider.of<Auth>(context, listen: false).user;
    
    if (user == null) return;
    
    // Seulement pour églises et serviteurs validés
    if (user.church == null && user.servant == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    try {
      final walletType = user.church != null ? 'church' : 'pastor';
      final walletId = user.church?.id ?? user.servant?.id ?? 0;
      
      final donationService = DonationWalletService();
      final response = await donationService.getReceivedDonations(
        recipientType: walletType,
        recipientId: walletId,
      );
      
      setState(() {
        _donations = response['data'] ?? [];
        _filteredDonations = _donations;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur chargement donations: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterDonations(String? query) {
    setState(() {
      _searchQuery = query ?? '';
      if (query == null || query.isEmpty) {
        _filteredDonations = _donations;
      } else {
        _filteredDonations = _donations.where((donation) {
          final donorName = (donation['donor_name'] ?? '').toLowerCase();
          final amount = donation['amount'].toString();
          return donorName.contains(query.toLowerCase()) || 
                 amount.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Historique des dons",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomFormTextField(
              label: "Recherche",
              prefix: cusIcon(Icons.search),
              onChanged: _filterDonations,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredDonations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.inbox,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? "Aucun don reçu pour le moment"
                                    : "Aucun résultat trouvé",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredDonations.length,
                          itemBuilder: (context, index) {
                            final donation = _filteredDonations[index];
                            return _buildDonationTile(donation);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationTile(Map<String, dynamic> donation) {
    final donorName = donation['donor_name'] ?? 'Anonyme';
    final amount = donation['amount'] ?? 0;
    final createdAt = donation['created_at'] != null
        ? DateTime.parse(donation['created_at'])
        : DateTime.now();

    return InkWell(
      onTap: () => _showDonationDetails(donation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: appMainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.handHoldingHeart,
                  color: appMainColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donorName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${createdAt.day} ${_getMonthName(createdAt.month)} ${createdAt.year} à ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "$amount Fr",
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: appMainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return months[month];
  }

  void _showDonationDetails(Map<String, dynamic> donation) {
    final donorName = donation['donor_name'] ?? 'Anonyme';
    final amount = donation['amount'] ?? 0;
    final message = donation['message'];
    final createdAt = donation['created_at'] != null
        ? DateTime.parse(donation['created_at'])
        : DateTime.now();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appMainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.handHoldingHeart,
                      color: appMainColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Détails du don",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const FaIcon(FontAwesomeIcons.xmark),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(Icons.person, "Donateur", donorName),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.attach_money, "Montant", "$amount Fr"),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.calendar_today, "Date",
                  "${createdAt.day}/${createdAt.month}/${createdAt.year} à ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}"),
              if (message != null && message.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  "Message",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appMainColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Fermer",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          "$label: ",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
