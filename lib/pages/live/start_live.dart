import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aesd/provider/live_provider.dart';
import 'package:aesd/pages/live/live_room.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/services/message.dart';

class StartLivePage extends StatefulWidget {
  const StartLivePage({Key? key}) : super(key: key);

  @override
  State<StartLivePage> createState() => _StartLivePageState();
}

class _StartLivePageState extends State<StartLivePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startLive() async {
    if (_titleController.text.isEmpty) {
      MessageService.showWarningMessage('Veuillez entrer un titre');
      return;
    }

    setState(() => _isCreating = true);

    final liveProvider = context.read<LiveProvider>();

    final room = await liveProvider.createLiveRoom(
      title: _titleController.text,
      description: _descriptionController.text,
      participantName: 'Utilisateur',
      participantId: 0,
      isPublic: _isPublic,
    );

    setState(() => _isCreating = false);

    if (room != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LiveRoomPage(
            roomName: room.roomName,
            isHost: true,
          ),
        ),
      );
    } else {
      MessageService.showErrorMessage(
        liveProvider.error ?? 'Erreur lors de la création du live',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff3ae700),
        title: const Text(
          'Démarrer un Live',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Illustration
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff3ae700), Color(0xff2a9000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff3ae700).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: cusFaIcon(
                      FontAwesomeIcons.wifi,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Description
              const Text(
                'Diffuser en Direct',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Partage ton message et rejoint la communauté',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Titre
              _buildTextField(
                controller: _titleController,
                label: 'Titre du Live',
                hint: 'Ex: Service du dimanche, Prière du soir...',
                icon: FontAwesomeIcons.heading,
                maxLines: 1,
              ),
              const SizedBox(height: 20),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (Optionnel)',
                hint: 'Décrivez le contenu de votre diffusion...',
                icon: FontAwesomeIcons.fileLines,
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Public switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xff3ae700).withOpacity(0.1),
                      const Color(0xff2a9000).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xff3ae700).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xff3ae700).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: cusFaIcon(
                        _isPublic
                            ? FontAwesomeIcons.earth
                            : FontAwesomeIcons.lock,
                        color: const Color(0xff3ae700),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visibilité',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _isPublic
                                ? 'Visible par tous'
                                : 'Visible par les membres uniquement',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() => _isPublic = value);
                      },
                      activeColor: const Color(0xff3ae700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Features
              _buildFeatureItem(
                icon: FontAwesomeIcons.share,
                title: 'Partage Facile',
                subtitle: 'Partagez le lien avec vos contacts',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                icon: FontAwesomeIcons.users,
                title: 'Communauté Active',
                subtitle: 'Connectez-vous avec des milliers de croyants',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                icon: FontAwesomeIcons.fileVideo,
                title: 'Enregistrement',
                subtitle: 'Le service est automatiquement enregistré',
              ),
              const SizedBox(height: 40),

              // Start Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff3ae700), Color(0xff2a9000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff3ae700).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isCreating ? null : _startLive,
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: _isCreating
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  cusFaIcon(
                                    FontAwesomeIcons.play,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Commencer le Live',
                                    style: TextStyle(
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
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff3ae700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: cusFaIcon(
                icon,
                color: const Color(0xff3ae700),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xff3ae700),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xff3ae700).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: cusFaIcon(
              icon,
              color: const Color(0xff3ae700),
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
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
