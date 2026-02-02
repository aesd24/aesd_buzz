import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:aesd/provider/live_provider.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/models/live_model.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/services/message.dart';
import 'dart:convert';

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
  final _messageController = TextEditingController();

  Room? _room;
  EventsListener<RoomEvent>? _listener;
  VideoTrack? _remoteVideoTrack;
  bool _isLoading = true;

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

    _connectToRoom();
  }

  Future<void> _connectToRoom() async {
    final liveProvider = context.read<LiveProvider>();
    LiveRoom? liveRoom = liveProvider.currentRoom;

    // Si on est pas l'hôte et qu'on n'a pas encore joint la room, on le fait maintenant
    if (!widget.isHost && (liveRoom == null || liveRoom.roomName != widget.roomName)) {
      final authProvider = context.read<Auth>();
      final user = authProvider.user;

      liveRoom = await liveProvider.joinLiveRoom(
        roomName: widget.roomName,
        participantName: user?.name ?? 'Spectateur',
        participantId: user?.id ?? 0,
      );
    }

    if (liveRoom == null || liveRoom.accessToken.isEmpty) {
      MessageService.showErrorMessage("Données de connexion manquantes");
      if (mounted) Navigator.pop(context);
      return;
    }

    // Check permissions (Microphone might be needed for listeners too in some cases, but focusing on Camera/Mic for host)
    if (widget.isHost) {
       await [Permission.camera, Permission.microphone].request();
    }

    try {
      // Connect to LiveKit Room
      _room = Room();
      _listener = _room!.createListener();

      _setUpListeners();

      await _room!.connect(
        liveRoom.liveKitServerUrl,
        liveRoom.accessToken,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );

      if (widget.isHost) {
        // Publish camera and microphone
        await _room!.localParticipant?.setCameraEnabled(true);
        await _room!.localParticipant?.setMicrophoneEnabled(true);
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      print('ERROR CONNECTING: $e');
      MessageService.showErrorMessage("Erreur de connexion LiveKit: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setUpListeners() {
    _listener!
      ..on<TrackSubscribedEvent>((event) {
        if (event.track is VideoTrack) {
          setState(() => _remoteVideoTrack = event.track as VideoTrack);
        }
      })
      ..on<TrackUnsubscribedEvent>((event) {
        if (event.track is VideoTrack) {
          setState(() => _remoteVideoTrack = null);
        }
      })
      ..on<LocalTrackPublishedEvent>((event) {
         setState(() {}); // Refresh state
      })
      ..on<LocalTrackUnpublishedEvent>((event) {
         setState(() {}); // Refresh state
      })
      ..on<RoomDisconnectedEvent>((event) {
         if (mounted) {
             MessageService.showInfoMessage("Le live est terminé");
             Navigator.pop(context);
         }
      });
  }

  @override
  void dispose() {
     _room?.disconnect();
    _room?.dispose();
    _messageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _shareRoom() {
    if (widget.roomInfo != null) {
      final String shareText =
          'Rejois-moi en live: ${widget.roomInfo!.shareUrl}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(shareText),
          action: SnackBarAction(
            label: 'Copier',
            onPressed: () {
              // Copy to clipboard logic would go here
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
    await _room?.disconnect(); // Disconnect form LiveKit
    
    final liveProvider = context.read<LiveProvider>();
    final success = await liveProvider.endLiveRoom();

    if (success) {
      MessageService.showSuccessMessage('Live terminé');
      if (mounted) Navigator.pop(context);
    } else {
      MessageService.showErrorMessage(
        liveProvider.error ?? 'Erreur lors de la terminaison du live',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveProvider = context.watch<LiveProvider>();
    final isAudioEnabled = _room?.localParticipant?.isMicrophoneEnabled() ?? false;
    final isVideoEnabled = _room?.localParticipant?.isCameraEnabled() ?? false;

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
          backgroundColor: Colors.transparent, // Transparent for overlay feel
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Container(
                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.red,
                       borderRadius: BorderRadius.circular(4)
                     ),
                     child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                   ),
                   const SizedBox(width: 8),
                   if (widget.roomInfo != null)
                     Text(
                       '👥 ${widget.roomInfo!.participantCount}',
                        style: const TextStyle(
                           color: Colors.white,
                           fontSize: 12, 
                           fontWeight: FontWeight.bold,
                           shadows: [Shadow(color: Colors.black, blurRadius: 4)]
                        ),
                     ),
                ],
              ),
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
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red)
                      ),
                      child: const Text(
                        'Terminer',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(
          children: [
            // Video Renderer
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xff3ae700)))
                    : _buildVideoContent(isVideoEnabled),
              ),
            ),

            // Bottom Gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  children: [
                    if (widget.isHost)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           _buildRoundButton(
                             icon: isAudioEnabled ? FontAwesomeIcons.microphone : FontAwesomeIcons.microphoneSlash,
                             isActive: isAudioEnabled,
                             onTap: () async {
                               final p = _room?.localParticipant;
                               if (p != null) {
                                  await p.setMicrophoneEnabled(!isAudioEnabled);
                                  setState(() {});
                               }
                             }
                           ),
                           const SizedBox(width: 24),
                           _buildRoundButton(
                             icon: isVideoEnabled ? FontAwesomeIcons.video : FontAwesomeIcons.videoSlash,
                             isActive: isVideoEnabled,
                             onTap: () async {
                               final p = _room?.localParticipant;
                               if (p != null) {
                                  await p.setCameraEnabled(!isVideoEnabled);
                                  setState(() {});
                               }
                             }
                           ),
                             const SizedBox(width: 24),
                            _buildRoundButton(
                                icon: FontAwesomeIcons.cameraRotate,
                                isActive: true,
                                onTap: () async {
                                    // Switch camera logic (requires getting track and calling switchCamera)
                                    // Simplified for MVP if using provided track helpers
                                }
                            ),
                        ],
                      ),
                    if (!widget.isHost)
                        Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                                _buildActionButton(
                                    icon: FontAwesomeIcons.share,
                                    label: 'Partager',
                                    onTap: _shareRoom
                                ),
                             ],
                        ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent(bool localVideoEnabled) {
    if (widget.isHost) {
      if (!localVideoEnabled) {
        return const Center(
          child: Text(
            "Caméra désactivée", 
            style: TextStyle(color: Colors.white)
          )
        );
      }
      // Local Host Video
      final track = _room?.localParticipant?.videoTrackPublications.firstOrNull?.track;
      if (track != null) {
        return VideoTrackRenderer(track as VideoTrack);
      } else {
        return const Center(child: CircularProgressIndicator(color: Color(0xff3ae700)));
      }
    } else {
      // Remote Viewer Video
      if ( _remoteVideoTrack != null) {
        return VideoTrackRenderer(_remoteVideoTrack!);
      } else {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xff3ae700)),
              const SizedBox(height: 16),
              Text(
                "En attente du flux vidéo...",
                style: TextStyle(color: Colors.grey[400]),
              )
            ],
          ),
        );
      }
    }
  }
  
  Widget _buildRoundButton({
      required IconData icon, 
      required bool isActive, 
      required VoidCallback onTap
  }) {
      return GestureDetector(
          onTap: onTap,
          child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.3)
              ),
              child: Center(
                  child: FaIcon(
                      icon,
                      color: isActive ? Colors.black : Colors.white,
                      size: 20
                  )
              )
          )
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
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            cusFaIcon(
              icon,
              color: Colors.white,
              size: 14,
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
}
