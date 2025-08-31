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
      await Provider.of<Testimony>(context, listen: false).getAny(id);
    } catch (e) {
      MessageService.showErrorMessage("Impossible de récupérer le témoignage");
    }
    setState(() {
      _isLoading = false;
    });
  }

  // lecture audio
  final _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  Future<void> _initAudioPlayer() async {
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
  }

  Future<void> _seekAudio(Duration position) async {
    setState(() => _position = position);
  }

  Future<void> _prepareAudioPlayer(String audioUrl) async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      await _player.setSourceUrl(audioUrl);
    } catch (e) {
      print("Erreur lors de la configuration de la source URL: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        MessageService.showErrorMessage(
          "Impossible de charger le flux audio: ${e.toString()}",
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final id = Get.arguments['id'];
      _getTestimony(id as int);
    });
    _initAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
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
                    testimony.mediaType == 'audio'
                        ? Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: mainColor, width: 1.5),
                            borderRadius: BorderRadius.circular(15),
                            color: mainColor.shade50,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: cusFaIcon(
                                  _isPlaying
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
                        )
                        : Placeholder(),
                  ],
                ),
              ),
            );
      },
    );
  }
}
