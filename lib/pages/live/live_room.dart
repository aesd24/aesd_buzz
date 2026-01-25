import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aesd/provider/live_provider.dart';
import 'package:aesd/models/live_model.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/services/message.dart';

class LiveRoomPage extends StatefulWidget {
  final String roomName;
  final LiveRoomInfo? roomInfo;
  final bool isHost;

  const LiveRoomPage({
    Key? key,
    required this.roomName,
    this.roomInfo,
    this.isHost = false,
  }) : super(key: key);

  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showChat = false;
  bool _audioEnabled = true;
  bool _videoEnabled = true;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _shareRoom() {
    if (widget.roomInfo != null) {
      // Using Flutter's native share functionality
      final String shareText =
          'Rejois-moi en live: ${widget.roomInfo!.shareUrl}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(shareText),
          action: SnackBarAction(
            label: 'Copier',
            onPressed: () {
              // Copy to clipboard
            },
          ),
        ),
      );
    }
  }

  void _endLive() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer le live'),
        content: const Text('Êtes-vous sûr de vouloir terminer cette diffusion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performEndLive();
            },
            child: const Text(
              'Terminer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _performEndLive() async {
    final liveProvider = context.read<LiveProvider>();
    final success = await liveProvider.endLiveRoom();

    if (success) {
      MessageService.showSuccessMessage('Live terminé');
      Navigator.pop(context);
    } else {
      MessageService.showErrorMessage(
        liveProvider.error ?? 'Erreur lors de la terminaison du live',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isHost) {
          _endLive();
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black54,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xffff4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'EN DIRECT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffff4444),
                    ),
                  ),
                ],
              ),
              if (widget.roomInfo != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.roomInfo!.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          actions: [
            if (widget.isHost)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: _endLive,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.stop,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Terminer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (widget.isHost) {
                _endLive();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Video Stream Area
              Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff3ae700), Color(0xff2a9000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: cusFaIcon(
                            FontAwesomeIcons.video,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (widget.roomInfo != null) ...[
                        Text(
                          widget.roomInfo!.hostName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '👥 ${widget.roomInfo!.participantCount} spectateurs',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    child: Column(
                      children: [
                        if (widget.isHost)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildControlButton(
                                icon: _audioEnabled
                                    ? FontAwesomeIcons.microphone
                                    : FontAwesomeIcons.microphoneSlash,
                                label: _audioEnabled ? 'Micro' : 'Muet',
                                onTap: () async {
                                  final liveProvider =
                                      context.read<LiveProvider>();
                                  await liveProvider
                                      .muteAudio(!_audioEnabled);
                                  setState(() => _audioEnabled = !_audioEnabled);
                                },
                                isActive: _audioEnabled,
                              ),
                              const SizedBox(width: 16),
                              _buildControlButton(
                                icon: _videoEnabled
                                    ? FontAwesomeIcons.video
                                    : FontAwesomeIcons.videoSlash,
                                label: _videoEnabled ? 'Caméra' : 'Arrêtée',
                                onTap: () async {
                                  final liveProvider =
                                      context.read<LiveProvider>();
                                  await liveProvider
                                      .muteVideo(!_videoEnabled);
                                  setState(() => _videoEnabled = !_videoEnabled);
                                },
                                isActive: _videoEnabled,
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildActionButton(
                                icon: FontAwesomeIcons.share,
                                label: 'Partager',
                                onTap: _shareRoom,
                              ),
                              const SizedBox(width: 16),
                              _buildActionButton(
                                icon: FontAwesomeIcons.heart,
                                label: 'J\'aime',
                                onTap: () {
                                  MessageService.showSuccessMessage(
                                    'Merci pour votre soutien! ❤️',
                                  );
                                },
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildActionButton(
                              icon: FontAwesomeIcons.comment,
                              label: 'Chat',
                              onTap: () {
                                setState(() => _showChat = !_showChat);
                              },
                            ),
                            if (widget.isHost) ...[
                              const SizedBox(width: 16),
                              _buildActionButton(
                                icon: FontAwesomeIcons.ellipsis,
                                label: 'Plus',
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                        _buildMoreOptionsSheet(),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Chat Panel
              if (_showChat)
                Positioned(
                  bottom: 160,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xff3ae700).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              cusFaIcon(
                                FontAwesomeIcons.comment,
                                color: const Color(0xff3ae700),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Chat en Direct',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _showChat = false),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Color(0xff3ae700),
                          height: 0,
                        ),
                        Container(
                          height: 150,
                          padding: const EdgeInsets.all(12),
                          child: ListView(
                            children: [
                              _buildChatMessage(
                                'Admin',
                                'Bienvenue dans le live!',
                                isAdmin: true,
                              ),
                              _buildChatMessage(
                                'Utilisateur',
                                'Merci! Bon service!',
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Votre message...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_messageController.text.isNotEmpty) {
                                    // Send message logic
                                    _messageController.clear();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff3ae700),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: cusFaIcon(
                                    FontAwesomeIcons.paperPlane,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xff3ae700)
              : Colors.red.shade600,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? const Color(0xff3ae700).withOpacity(0.3)
                  : Colors.red.shade300.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            cusFaIcon(
              icon,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xff3ae700).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            cusFaIcon(
              icon,
              color: const Color(0xff3ae700),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xff3ae700),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOptionsSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionTile(
            icon: FontAwesomeIcons.share,
            title: 'Partager le live',
            onTap: () {
              Navigator.pop(context);
              _shareRoom();
            },
          ),
          _buildOptionTile(
            icon: FontAwesomeIcons.users,
            title: 'Gérer les participants',
            onTap: () {
              Navigator.pop(context);
              MessageService.showInfoMessage('Bientôt disponible');
            },
          ),
          _buildOptionTile(
            icon: FontAwesomeIcons.gear,
            title: 'Paramètres',
            onTap: () {
              Navigator.pop(context);
              MessageService.showInfoMessage('Bientôt disponible');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xff3ae700).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xff3ae700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: cusFaIcon(
                    icon,
                    color: const Color(0xff3ae700),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xff3ae700),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessage(
    String name,
    String message, {
    bool isAdmin = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAdmin)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff3ae700), Color(0xff2a9000)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '👤',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            )
          else
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isAdmin
                        ? const Color(0xff3ae700)
                        : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
