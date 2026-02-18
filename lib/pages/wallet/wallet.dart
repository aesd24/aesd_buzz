import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/tiles.dart';
import 'package:aesd/pages/wallet/deposit.dart';
import 'package:aesd/pages/wallet/send.dart';
import 'package:aesd/pages/wallet/transactions.dart';
import 'package:aesd/pages/wallet/withdrawing.dart';
import 'package:aesd/pages/wallet/withdrawal_request_page.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/provider/wallet_provider.dart';
import 'package:aesd/services/donation_wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

// Enum pour le type de wallet affiché
enum WalletType { personal, church }

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> with SingleTickerProviderStateMixin {
  bool _password = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Wallet switching
  WalletType _activeWalletType = WalletType.personal;
  bool _isRefreshing = false;
  
  // Données de donation
  bool _isLoadingDonations = true;
  int _donationBalance = 0;
  List<dynamic> _receivedDonations = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // V\u00e9rifier si on doit ouvrir directement le wallet église
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args != null && args['openChurchWallet'] == true) {
        setState(() => _activeWalletType = WalletType.church);
      }
      _loadWalletData();
    });
  }
  
  Future<void> _loadWalletData() async {
    setState(() {
      _isRefreshing = true;
      _isLoadingDonations = true;
    });
    
    final user = Provider.of<Auth>(context, listen: false).user;
    
    if (user == null) {
      setState(() {
        _isRefreshing = false;
        _isLoadingDonations = false;
      });
      return;
    }
    
    // Déterminer le type et ID selon le wallet actif
    String walletType;
    int walletId;
    
    if (_activeWalletType == WalletType.church && user.church != null) {
      walletType = 'church';
      walletId = user.church!.id;
    } else if (_activeWalletType == WalletType.personal && user.servant != null) {
      walletType = 'pastor';
      walletId = user.servant!.id;
    } else if (user.church != null) {
      // Fallback: église seule
      walletType = 'church';
      walletId = user.church!.id;
    } else if (user.servant != null) {
      // Fallback: pasteur seul
      walletType = 'pastor';
      walletId = user.servant!.id;
    } else {
      // Aucun wallet disponible
      setState(() {
        _isRefreshing = false;
        _isLoadingDonations = false;
      });
      return;
    }
    
    try {
      final donationService = DonationWalletService();
      
      // Charger le solde
      final balanceResponse = await donationService.getBalance(
        walletType: walletType,
        walletId: walletId,
      );
      
      // Charger les dons reçus
      final donationsResponse = await donationService.getReceivedDonations(
        recipientType: walletType,
        recipientId: walletId,
      );
      
      setState(() {
        _donationBalance = balanceResponse['balance'] ?? 0;
        _receivedDonations = donationsResponse['data'] ?? [];
        _isLoadingDonations = false;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDonations = false;
        _isRefreshing = false;
      });
    }
  }
  
  Widget _buildToggleOption(String label, WalletType type) {
    final isActive = _activeWalletType == type;
    
    return GestureDetector(
      onTap: () {
        if (_activeWalletType != type) {
          setState(() => _activeWalletType = type);
          _loadWalletData(); // Recharger avec nouveau type
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isActive ? appMainColor : Colors.white.withOpacity(0.7),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeColors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: cusFaIcon(
              FontAwesomeIcons.arrowLeft,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Text(
          "Mon Portefeuille",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isRefreshing ? Icons.hourglass_empty : Icons.refresh_rounded,
              color: Colors.white,
            ),
            onPressed: _isRefreshing ? null : _loadWalletData,
          ),
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec gradient et glassmorphism
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      appMainColor,
                      appMainColor.withOpacity(0.8),
                      const Color(0xff2a9000),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Cercles décoratifs
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    
                    // Contenu
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 100,
                        left: 24,
                        right: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Toggle wallet type (Personal / Église)
                          Consumer<Auth>(builder: (context, auth, _) {
                            final user = auth.user;
                            if (user == null) return SizedBox.shrink();
                            
                            final hasChurch = user.church != null;
                            final hasServant = user.servant != null;
                            
                            // Si pasteur AVEC église → Afficher toggle
                            if (hasChurch && hasServant) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildToggleOption('Personnel', WalletType.personal),
                                    _buildToggleOption('Église', WalletType.church),
                                  ],
                                ),
                              );
                            }
                            return SizedBox.shrink();
                          }),
                          Text(
                            "Solde disponible",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                _password 
                                  ? "${(_donationBalance / 1).toStringAsFixed(0)}" 
                                  : "********",
                                style: GoogleFonts.orbitron(
                                  fontSize: 48,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(height: 20),
                                  Text(
                                    "XOF",
                                    style: GoogleFonts.orbitron(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _password = !_password;
                                  });
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: FaIcon(
                                    _password
                                        ? FontAwesomeIcons.eye
                                        : FontAwesomeIcons.eyeSlash,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Boutons d'action avec glassmorphism
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: appMainColor.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildModernActionButton(
                                  icon: FontAwesomeIcons.arrowDown,
                                  label: "Retirer",
                                  color: const Color(0xffff9800),
                                    onTap: () async {
                                      final user = Provider.of<Auth>(context, listen: false).user;
                                      
                                      if (user == null) return;

                                      // Cas Utilisateur Standard (Ni église, ni serviteur) -> Retrait Mobile Money direct
                                      if (user.church == null && user.servant == null) {
                                        Get.to(() => WithDrawingPage());
                                        return;
                                      }

                                      String walletType;
                                      int walletId;
                                      
                                      // Utiliser le wallet ACTIF sélectionné via les boutons toggle
                                      if (_activeWalletType == WalletType.church && user.church != null) {
                                        walletType = 'church';
                                        walletId = user.church!.id;
                                      } else if (_activeWalletType == WalletType.personal && user.servant != null) {
                                        walletType = 'pastor';
                                        walletId = user.servant!.id;
                                      } else {
                                        // Fallback par défaut si quelque chose ne va pas
                                        walletType = user.church != null ? 'church' : 'pastor';
                                        walletId = user.church?.id ?? user.servant?.id ?? 0;
                                      }
                                      
                                      // Récupérer le solde des dons depuis le backend pour ce wallet spécifique
                                      try {
                                        final donationWalletService = DonationWalletService();
                                        final balanceResponse = await donationWalletService.getBalance(
                                          walletType: walletType,
                                          walletId: walletId,
                                        );
                                        
                                        final donationBalance = balanceResponse['balance'] ?? 0;
                                        
                                        Get.to(() => WithdrawalRequestPage(
                                          walletType: walletType,
                                          walletId: walletId,
                                          currentBalance: donationBalance as int,
                                        ));
                                      } catch (e) {
                                        print('Erreur récupération solde donations: $e');
                                        // En cas d'erreur, utiliser le solde local si c'est le même wallet, sinon 0
                                        Get.to(() => WithdrawalRequestPage(
                                          walletType: walletType,
                                          walletId: walletId,
                                          currentBalance: 0,
                                        ));
                                      }
                                    },
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.grey[300],
                              ),
                              Expanded(
                                child: _buildModernActionButton(
                                  icon: FontAwesomeIcons.clockRotateLeft,
                                  label: "Historique",
                                  color: const Color(0xff9c27b0),
                                  onTap: () => Get.to(() => TransactionsPage()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Section Transactions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Transactions récentes",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Get.to(() => TransactionsPage()),
                          child: Row(
                            children: [
                              Text(
                                "Tout voir",
                                style: GoogleFonts.poppins(
                                  color: appMainColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              FaIcon(
                                FontAwesomeIcons.chevronRight,
                                size: 12,
                                color: appMainColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Liste des donations reçues
                    _isLoadingDonations
                      ? const Center(child: CircularProgressIndicator())
                      : _receivedDonations.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.inbox,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Pas d'historique pour le moment",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: _receivedDonations.take(5).toList().asMap().entries.map((entry) {
                              final index = entry.key;
                              final donation = entry.value;
                              
                              return TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 300 + (index * 100)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _buildDonationTile(
                                  context,
                                  donation: donation,
                                ),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTransactionTile(
    BuildContext context, {
    required String label,
    required int amount,
    required DateTime date,
    required bool isIncoming,
  }) {
    return Container(
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
              color: isIncoming
                  ? appMainColor.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(
                isIncoming
                    ? FontAwesomeIcons.arrowDown
                    : FontAwesomeIcons.arrowUp,
                color: isIncoming ? appMainColor : Colors.orange,
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
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${date.day}/${date.month}/${date.year}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${isIncoming ? '+' : '-'}$amount XOF",
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isIncoming ? appMainColor : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDonationTile(BuildContext context, {required Map<String, dynamic> donation}) {
    final donorName = donation['donor_name'] ?? 'Anonyme';
    final amount = donation['amount'] ?? 0;
    final createdAt = donation['created_at'] != null 
        ? DateTime.parse(donation['created_at']) 
        : DateTime.now();
    
    return InkWell(
      onTap: () => _showDonationDetails(context, donation),
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
                    "${createdAt.day}/${createdAt.month}/${createdAt.year}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "+$amount XOF",
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
  
  void _showDonationDetails(BuildContext context, Map<String, dynamic> donation) {
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
              _buildDetailRow(Icons.attach_money, "Montant", "$amount XOF"),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.calendar_today, "Date", 
                  "${createdAt.day}/${createdAt.month}/${createdAt.year}"),
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
