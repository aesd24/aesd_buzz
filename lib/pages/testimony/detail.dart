import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/provider/testimony.dart';
import 'package:aesd/services/message.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // Importer video_player
import 'package:chewie/chewie.dart'; // Importer chewie
import 'package:flutter/services.dart';

class TestimonyDetail extends StatefulWidget {
  const TestimonyDetail({super.key});

  @override
  State<TestimonyDetail> createState() => _TestimonyDetailState();
}

class _TestimonyDetailState extends State<TestimonyDetail> {
  bool _isLoading = true;

  Future<void> _getTestimony(int id) async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<Testimony>(context, listen: false).getAny(id).then((_) {
        final testimony =
            Provider.of<Testimony>(context, listen: false).selectedTestimony!;
        initialize(testimony.mediaUrl, isAudio: testimony.mediaType == 'audio');
      });
    } catch (e) {
      MessageService.showErrorMessage("Impossible de récupérer le témoignage");
    }
    setState(() {
      _isLoading = false;
    });
  }

  // lecture vidéo
  bool _isVideoLoading = false;
  bool _isVideoInitialized = false;
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  Future<void> _initializeVideoPlayer(String mediaUrl) async {
    if (_isVideoInitialized && _videoPlayerController.dataSource == mediaUrl) {
      // Déjà initialisé avec la même URL
      return;
    }

    setState(() {
      _isVideoLoading = true;
      _isVideoInitialized =
          false; // Marquer comme non initialisé tant que ce n'est pas terminé
    });

    // Si un ancien contrôleur existe, le disposer
    if (_chewieController != null) {
      _chewieController!.pause(); // Pause avant de disposer
      _chewieController!.dispose();
      _chewieController = null;
    }
    // _videoPlayerController est initialisé ci-dessous, s'il y en avait un avant,
    // sa libération est gérée par la nouvelle initialisation ou dispose() si erreur.

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(mediaUrl),
      );
      await _videoPlayerController.initialize(); // Attendre l'initialisation

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay:
            false, // Ne pas démarrer automatiquement, l'utilisateur cliquera sur play
        looping: false, // Ne pas lire en boucle par défaut
        allowedScreenSleep:
            false, // Empêcher l'écran de se mettre en veille pendant la lecture
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              "Erreur de lecture vidéo: $errorMessage",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      );
      setState(() {
        _isVideoInitialized = true; // Marquer comme initialisé
        _isVideoLoading = false;
      });
    } catch (e) {
      print("Erreur d'initialisation du lecteur vidéo: $e");
      MessageService.showErrorMessage(
        "Impossible de charger la vidéo: ${e.toString()}",
      );
      setState(() {
        _isVideoLoading = false;
        _isVideoInitialized = false;
      });
    }
  }

  // lecture audio
  final _audioPlayer = AudioPlayer();
  bool _isAudioLoading = false;
  bool _audioInitialized = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _playerState = PlayerState.stopped;

  Future<void> _initAudioPlayer(String audioUrl) async {
    await _prepareAudioPlayer(audioUrl);
    _audioPlayer.onDurationChanged.listen((d) => setState(() => _duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => _position = p));
    _audioPlayer.onPlayerStateChanged.listen(
      (s) => setState(() => _playerState = s),
    );
    setState(() {});
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      MessageService.showErrorMessage("Impossible de charger l'audio");
    }
  }

  Future<void> _pauseResumeAudio() async {
    try {
      if (_playerState == PlayerState.paused) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      // ... gestion d'erreur si nécessaire ...
    }
  }

  Future<void> _seekAudio(Duration position) async {
    setState(() {
      _position = position;
    });
    await _audioPlayer.seek(_position);
  }

  Future<void> _prepareAudioPlayer(String audioUrl) async {
    setState(() => _isAudioLoading = true);
    try {
      print("audioUrl: $audioUrl");
      await _audioPlayer.setSourceUrl(audioUrl).then((value) async {
        await _audioPlayer.getDuration().then((value) {
          if (value != null) setState(() => _duration = value);
        });

        await _audioPlayer.getCurrentPosition().then((value) {
          if (value != null) setState(() => _position = value);
        });
      });
      setState(() => _audioInitialized = true);
    } catch (e) {
      e.printError();
      setState(() {
        _audioInitialized = false;
        _isAudioLoading = false;
      });
      MessageService.showErrorMessage(
        "Impossible de charger le flux audio",
      );
    } finally {
      setState(() => _isAudioLoading = false);
      print("terminé: $_isAudioLoading");
    }
  }

  Future initialize(String mediaUrl, {required bool isAudio}) async {
    try {
      if (!isAudio) {
        _initializeVideoPlayer(mediaUrl);
      } else {
        await _initAudioPlayer(mediaUrl);
      }
    } catch (e) {
      //
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final id = Get.arguments['id'];
      _getTestimony(id as int);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<Testimony>(
      builder: (context, provider, child) {
        if (provider.selectedTestimony == null) {
          return Scaffold(
            appBar: AppBar(leading: customBackButton()),
            body: Center(child: notFoundTile(text: "Témoignage introuvable !")),
          );
        }
        final testimony = provider.selectedTestimony!;
        final mainColor =
            testimony.mediaType == 'audio' ? Colors.blue : Colors.deepPurple;
        if (testimony.mediaType == 'audio') {
          _prepareAudioPlayer(testimony.mediaUrl);
        }
        return _isLoading
            ? Scaffold(body: SafeArea(child: ListShimmerPlaceholder()))
            : Scaffold(
              appBar: AppBar(
                leading: customBackButton(),
                title: Text(
                  "Témoignage",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: cusFaIcon(
                      testimony.mediaType == 'audio'
                          ? FontAwesomeIcons.music
                          : FontAwesomeIcons.film,
                    ),
                  ),
                ],
                centerTitle: true,
              ),
              body: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(testimony.title, style: mainTextStyle),
                    testimony.isAnonymous
                        ? Text("Anonyme")
                        : Text(testimony.user!.name),
                    SizedBox(height: 25),
                    if (testimony.mediaType == 'audio')
                      (_isAudioLoading && !_audioInitialized)
                          ? imageShimmerPlaceholder(height: 70)
                          : Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: mainColor, width: 1.5),
                              borderRadius: BorderRadius.circular(15),
                              color: mainColor.shade50,
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (_playerState == PlayerState.stopped){
                                      _playAudio(testimony.mediaUrl);
                                    } else {
                                      _pauseResumeAudio();
                                    }
                                  },
                                  icon: cusFaIcon(
                                    _playerState == PlayerState.playing
                                        ? FontAwesomeIcons.pause
                                        : FontAwesomeIcons.play,
                                    color: Colors.white,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      mainColor,
                                    ),
                                    foregroundColor: WidgetStatePropertyAll(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Slider(
                                    min: 0,
                                    max: _duration.inMilliseconds.toDouble(),
                                    value: _position.inMilliseconds.toDouble(),
                                    onChanged: (value) {
                                      _seekAudio(
                                        Duration(milliseconds: value.toInt()),
                                      );
                                    },
                                    activeColor: notifire.getMainColor,
                                    inactiveColor: notifire.getMaingey,
                                    thumbColor: notifire.getMainColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    if (testimony.mediaType == 'video')
                      _isVideoLoading
                          ? imageShimmerPlaceholder(height: size.height * .3)
                          : _chewieController != null
                          ? SizedBox(
                            height: size.height * .3,
                            width: size.width,
                            child: Chewie(controller: _chewieController!),
                          )
                          : Center(
                            child: Text("La vidéo n'est pas disponible !"),
                          ),
                  ],
                ),
              ),
            );
      },
    );
  }
}
