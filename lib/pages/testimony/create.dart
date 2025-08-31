import 'dart:async';
import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/functions/camera_functions.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/provider/testimony.dart';
import 'package:aesd/services/message.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class CreateTestimony extends StatefulWidget {
  const CreateTestimony({super.key});

  @override
  State<CreateTestimony> createState() => _CreateTestimonyState();
}

class _CreateTestimonyState extends State<CreateTestimony> {
  File? _file;
  String? path;
  List<String> allowedExtensions = ['mp3', 'm4a', 'ogg'];
  bool _isLoading = false;

  // Décompte du temps d'enregistrement
  Duration _timeLeft = Duration(seconds: 0);
  Timer? _timer;
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft += const Duration(seconds: 1);
      });
    });
  }

  void reInitData() {
    _file = null;
    _timeLeft = Duration(seconds: 0);
    _duration = Duration(seconds: 0);
    _position = Duration(seconds: 0);
    _stopTimer();
    _player.setSourceDeviceFile('');
    _recordAudio = true;
    _isRecording = false;
    _isRecordPaused = false;
    _isAudioPlaying = false;
    _wantRecordAudio = false;
    setState(() {});
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  // form datas
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool isAnonymous = false;

  // audio
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  bool _recordAudio = true;
  bool _isRecording = false;
  bool _isRecordPaused = false;
  bool _isAudioPlaying = false;
  bool _wantRecordAudio = false;

  // lecteur de musique
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // sound record functions
  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.mp3';
      await _recorder.start(RecordConfig(), path: path);
      _isRecording = await _recorder.isRecording();
      _startTimer();
      setState(() {});
    } else {
      MessageService.showErrorMessage(
        "Vous n'avez pas les permissions pour enregistrer un audio",
      );
    }
  }

  Future<void> _stopRecording() async {
    _isRecording = await _recorder.isRecording();
    final filePath = await _recorder.stop();
    if (filePath != null) {
      _file = File(filePath);
      print(_file!.path);
      _player.setSourceDeviceFile(_file!.path);
    } else {
      MessageService.showErrorMessage("Impossible de sauvegarder l'audio");
    }
    _stopTimer();
    setState(() {});
  }

  Future<void> pauseOrUnpauseRecording() async {
    if (_isRecording) {
      if (_isRecordPaused) {
        await _recorder.resume();
        _startTimer();
      } else {
        await _recorder.pause();
        _stopTimer();
      }
      setState(() {
        _isRecordPaused = !_isRecordPaused;
      });
    }
  }

  // Fonctions pour jouer l'audio
  Future<void> _playAudio() async {
    try {
      if (_file != null) {
        await _player.play(DeviceFileSource(_file!.path));
        setState(() => _isAudioPlaying = true);
      }
    } catch (e) {
      MessageService.showErrorMessage("Impossible de jouer l'audio");
    }
  }

  Future<void> _pauseAudio() async {
    await _player.pause();
    setState(() => _isAudioPlaying = false);
  }

  Future<void> _seekAudio(Duration position) async {
    setState(() => _position = position);
    await _player.seek(_position);
  }

  // Obtenir l'audio depuis les fichiers
  Future getAudioFromFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
      _player.setSourceDeviceFile(_file!.path);
    }
  }

  Future<void> _initAudioPlayer() async {
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
  }

  // soumettre les données
  Future<void> _submitData(int userId) async {
    print('fonction lancée');
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // TODO: Implement testimony data sending
        await Provider.of<Testimony>(context, listen: false)
            .create({
              'title': _titleController.text,
              'is_anonymous': isAnonymous,
              'media': _file!.path,
              'mediaType': _recordAudio ? 'audio' : 'video',
              'user_id': userId,
            })
            .then((value) async {
              Provider.of<Testimony>(
                context,
                listen: false,
              ).getAll().then((value) => Get.back());
              MessageService.showSuccessMessage(
                "Témoignage enregistré avec succès",
              );
            });
      } on HttpException catch (e) {
        MessageService.showErrorMessage(e.message);
      } on DioException {
        MessageService.showErrorMessage(
          "Erreur de connexion. Vérifiez votre connexion internet",
        );
      } catch (e) {
        MessageService.showErrorMessage(
          "Une erreur inattendu s'est produite !",
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      MessageService.showWarningMessage(
        "Remplissez correctement le formulaire",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _recorder.stop();
    _recorder.dispose();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Auth>(context, listen: false).user!;
    return DefaultTabController(
      length: 2,
      child: Container(
        height: MediaQuery.of(context).size.height * .9,
        decoration: BoxDecoration(
          color: notifire.getbgcolor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: 70,
            leadingWidth: 100,
            leading: Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: cusFaIcon(FontAwesomeIcons.chevronDown),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 3.0),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: notifire.getMainColor,
                    backgroundImage:
                        user.photo != null
                            ? FastCachedImageProvider(user.photo!)
                            : null,
                    child:
                        user.photo != null
                            ? null
                            : cusFaIcon(
                              FontAwesomeIcons.solidUser,
                              color: notifire.getbgcolor,
                            ),
                  ),
                ),
              ],
            ),
            actions: [
              if (!_wantRecordAudio && _file == null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: cusFaIcon(FontAwesomeIcons.film, size: 15),
                ),

                Switch(
                  value: _recordAudio,
                  inactiveThumbColor: notifire.getMainText,
                  onChanged: (value) {
                    setState(() {
                      _recordAudio = value;
                    });
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: cusFaIcon(FontAwesomeIcons.microphone, size: 15),
                ),
              ],

              if (_file != null)
                IconButton(
                  onPressed: () => reInitData(),
                  icon: cusFaIcon(FontAwesomeIcons.arrowRotateLeft),
                ),

              Padding(
                padding: EdgeInsets.only(right: 10),
                child:
                    _isLoading
                        ? SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                        : CustomTextButton(
                          label: "Envoyer",
                          disabled: _file == null,
                          onPressed: () async => await _submitData(user.id!),
                        ),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                // formulaire
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomFormTextField(
                          controller: _titleController,
                          label: "Titre du témoignage",
                          validate: true,
                        ),
                        CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: notifire.getMainColor,
                          checkColor: Colors.white,
                          side: BorderSide(color: notifire.getMainText),
                          value: isAnonymous,
                          onChanged:
                              (value) =>
                                  setState(() => isAnonymous = !isAnonymous),
                          title: Text(
                            isAnonymous
                                ? "Témoignage anonyme"
                                : "Dévoiler mon identité",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Partie de l'enregistrement du fichier
                _recordAudio ? _buildRecordAudio() : _buildRecordVideo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListenAudio() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 17),
      decoration: BoxDecoration(
        color: notifire.getbgcolor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: notifire.getMaingey, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: IconButton(
                  onPressed:
                      () => _isAudioPlaying ? _pauseAudio() : _playAudio(),
                  icon: cusFaIcon(
                    _isAudioPlaying
                        ? FontAwesomeIcons.pause
                        : FontAwesomeIcons.play,
                    color: Colors.white,
                  ),
                  style: ButtonStyle(
                    overlayColor: WidgetStatePropertyAll(
                      notifire.getbgcolor.withAlpha(50),
                    ),
                    backgroundColor: WidgetStatePropertyAll(
                      notifire.getMainColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: notifire.getMaingey, width: 1),
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inMilliseconds.toDouble(),
                    value: _position.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      _seekAudio(Duration(milliseconds: value.toInt()));
                    },
                    activeColor: notifire.getMainColor,
                    inactiveColor: notifire.getMaingey,
                    thumbColor: notifire.getMainColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            '${getTimeInString(_position)} / ${getTimeInString(_duration)}',
            style: TextStyle(color: notifire.getMaingey),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioRecording() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isRecording) ...[
                Text(
                  getTimeInString(_timeLeft),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
              ],
              Center(
                child:
                    _isRecording
                        ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: notifire.getbgcolor,
                            boxShadow: [
                              BoxShadow(
                                color: notifire.getMaingey.withAlpha(70),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => pauseOrUnpauseRecording(),
                                icon: cusFaIcon(
                                  _isRecordPaused
                                      ? FontAwesomeIcons.play
                                      : FontAwesomeIcons.pause,
                                  color: _isRecordPaused ? null : Colors.red,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _stopRecording(),
                                icon: cusFaIcon(FontAwesomeIcons.stop),
                              ),
                            ],
                          ),
                        )
                        : GestureDetector(
                          onTap: () => _startRecording(),
                          child: Container(
                            padding: EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: notifire.getbgcolor,
                              boxShadow: [
                                BoxShadow(
                                  color: notifire.getMaingey,
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: cusFaIcon(
                              FontAwesomeIcons.microphone,
                              color: Colors.blue,
                              size: 25,
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        if (!_isRecording)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _wantRecordAudio = false;
              });
            },
            label: Text("Annuler"),
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(notifire.getMainText),
              overlayColor: WidgetStatePropertyAll(
                notifire.getMaingey.withAlpha(50),
              ),
            ),
            icon: cusFaIcon(FontAwesomeIcons.chevronLeft),
          ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _buildRecordAudio() {
    if (_file != null) {
      return _buildListenAudio();
    }
    return _wantRecordAudio
        ? _buildAudioRecording()
        : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _customButton(
                icon: FontAwesomeIcons.microphone,
                label: "Enregistrer",
                onPressed: () {
                  setState(() {
                    _wantRecordAudio = true;
                  });
                },
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _customButton(
                icon: FontAwesomeIcons.fileAudio,
                label: "Charger",
                onPressed: () => getAudioFromFiles(),
              ),
            ),
          ],
        );
  }

  // video widgets
  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: notifire.getbgcolor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: notifire.getMaingey, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              color: notifire.getMainColor.withAlpha(70),
            ),
            child: Center(child: cusFaIcon(FontAwesomeIcons.film, size: 30)),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text("Fichier vidéo: ${_file!.path.split('/').last}"),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordVideo() {
    if (_file != null) {
      return _buildVideoPreview();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _customButton(
            icon: FontAwesomeIcons.video,
            label: "Filmer",
            onPressed: () async {
              try {
                _file = await pickVideo(camera: true);
                setState(() {});
              } catch (e) {
                MessageService.showWarningMessage(e.toString());
              }
            },
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _customButton(
            icon: FontAwesomeIcons.fileVideo,
            label: "Charger",
            onPressed: () async {
              try {
                _file = await pickVideo();
                setState(() {});
              } catch (e) {
                MessageService.showWarningMessage(e.toString());
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _customButton({
    required IconData icon,
    required String label,
    required void Function() onPressed,
  }) {
    return InkWell(
      onTap: () => onPressed(),
      child: Container(
        padding: EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: notifire.getbgcolor,
          boxShadow: [
            BoxShadow(
              color: notifire.getMaingey,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            cusFaIcon(icon, size: 30),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
