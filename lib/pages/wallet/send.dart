import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/provider/servant.dart';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/models/servant_model.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  String _receiverType = "church";
  dynamic _selectedRecipient; // Can be ChurchModel or ServantModel
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<dynamic> _recipients = []; // List of churches or servants
  bool _isLoadingRecipients = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadRecipients();
  }

  void _loadRecipients() async {
    setState(() {
      _isLoadingRecipients = true;
    });

    try {
      if (_receiverType == "church") {
        final churchProvider = Provider.of<Church>(context, listen: false);
        await churchProvider.fetchChurches();
        setState(() {
          _recipients = churchProvider.churches;
        });
      } else {
        final servantProvider = Provider.of<Servant>(context, listen: false);
        await servantProvider.fetchServants();
        setState(() {
          _recipients = servantProvider.servants;
        });
      }
    } catch (e) {
      print('Erreur chargement destinataires: $e');
      MessageService.showErrorMessage('Erreur lors du chargement des destinataires');
    } finally {
      setState(() {
        _isLoadingRecipients = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _selectRecipient() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Choisissez le destinataire",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: _isLoadingRecipients
                  ? const Center(child: CircularProgressIndicator())
                  : _recipients.isEmpty
                      ? Center(
                          child: Text(
                            _receiverType == "church"
                                ? "Aucune église disponible"
                                : "Aucun serviteur de Dieu disponible",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _recipients.length,
                          itemBuilder: (context, index) {
                            final recipient = _recipients[index];
                            final String name;
                            final String? location;
                            final IconData icon;

                            if (_receiverType == "church") {
                              final church = recipient as ChurchModel;
                              name = church.name ?? "Église sans nom";
                              location = church.address; // ChurchModel uses 'address'
                              icon = FontAwesomeIcons.church;
                            } else {
                              final servant = recipient as ServantModel;
                              name = servant.user?.name ?? "Serviteur sans nom"; // ServantModel has user.name
                              location = servant.church?.address; // Get address from church
                              icon = FontAwesomeIcons.user;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [appMainColor, appMainColor.withOpacity(0.8)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: appMainColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedRecipient = recipient;
                                    });
                                    Navigator.pop(context);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: FaIcon(
                                        icon,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      name,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: location != null
                                        ? Text(
                                            location,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMoney() {
    if (_selectedRecipient == null) {
      MessageService.showWarningMessage('Veuillez sélectionner un destinataire');
      return;
    }

    if (_amountController.text.isEmpty || double.tryParse(_amountController.text) == null) {
      MessageService.showWarningMessage('Veuillez entrer un montant valide');
      return;
    }

    // TODO: Créer un endpoint backend POST /api/wallet/send
    MessageService.showInfoMessage('Fonctionnalité en développement');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
          "Envoyer de l'argent",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [appMainColor, const Color(0xff2a9000)],
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xff2196f3),
                      const Color(0xff2196f3).withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff2196f3).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: cusFaIcon(
                    FontAwesomeIcons.paperPlane,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Type de destinataire
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Type de destinataire",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _receiverType,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: cusFaIcon(
                            FontAwesomeIcons.userGroup,
                            color: appMainColor,
                            size: 20,
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: "church", child: Text("Une église")),
                        DropdownMenuItem(value: "servant", child: Text("Un serviteur de Dieu")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _receiverType = value!;
                          _selectedRecipient = null; // Reset selection
                          _loadRecipients(); // Reload recipients
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sélection du destinataire
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Destinataire",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _selectRecipient,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedRecipient != null ? appMainColor : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            cusFaIcon(
                              FontAwesomeIcons.user,
                              color: _selectedRecipient != null ? appMainColor : Colors.grey[400]!,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedRecipient != null
                                    ? (_receiverType == "church"
                                        ? (_selectedRecipient as ChurchModel).name ?? "Église"
                                        : (_selectedRecipient as ServantModel).user?.name ?? "Serviteur")
                                    : "Choisissez le destinataire",
                                style: GoogleFonts.poppins(
                                  color: _selectedRecipient != null ? Colors.grey[800] : Colors.grey[400],
                                  fontWeight: _selectedRecipient != null ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            FaIcon(
                              FontAwesomeIcons.chevronRight,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Montant
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Montant",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: appMainColor,
                      ),
                      decoration: InputDecoration(
                        hintText: "0",
                        hintStyle: TextStyle(color: Colors.grey[300]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: cusFaIcon(
                            FontAwesomeIcons.coins,
                            color: appMainColor,
                            size: 20,
                          ),
                        ),
                        suffixText: "XOF",
                        suffixStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: appMainColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bouton Envoyer
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff2196f3), Color(0xff1976d2)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff2196f3).withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _sendMoney,
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            cusFaIcon(
                              FontAwesomeIcons.paperPlane,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Envoyer",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
