import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/models/quiz_result_model.dart';
import 'package:aesd/provider/quiz.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class QuizResultPage extends StatefulWidget {
  const QuizResultPage({
    super.key,
    required this.quizId,
    required this.answers,
    required this.timeElapse,
  });

  final int quizId;
  final Map<String, List<int>> answers;
  final Duration timeElapse;

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  bool isLoading = false;
  bool isSucceeded = false;
  QuizResultModel? resultData;

  Future<void> sendResponses() async {
    try {
      setState(() => isLoading = true);
      await Provider.of<Quiz>(context, listen: false)
          .sendResponses(
            widget.quizId,
            answers: widget.answers,
            timeElapsed: getTimeInString(widget.timeElapse),
          )
          .then((value) {
            setState(() {
              resultData = QuizResultModel.fromJson(value);
              isSucceeded = true;
            });
            final quizProvider = Provider.of<Quiz>(context, listen: false);
            quizProvider.markQuizAsPlayed(
              widget.quizId,
              score: value['score'] is int ? value['score'] : int.tryParse(value['score']?.toString() ?? '0'),
              timeRemaining: value['time_remaining']?.toString(),
            );
            quizProvider.getAll();
          });
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException catch (e) {
      MessageService.showErrorMessage(
        "Erreur réseau. Vérifiez votre connexion internet",
      );
      e.printError();
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu s'est produite");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    sendResponses();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!isSucceeded || resultData == null) {
      return SafeArea(
        child: Center(
          child: notFoundTile(text: "Impossible d'envoyer les réponses"),
        ),
      );
    }
    
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icone et texte de succès
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  children: [
                    cusFaIcon(
                      FontAwesomeIcons.circleCheck,
                      color: notifire.getMainColor,
                      size: 70,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        resultData!.getPerformanceMessage(),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(color: notifire.getMainColor, fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),

              // Afficher les résultats
              SingleChildScrollView(
                child: Column(
                  children: [
                    // ✅ NOUVEAU: Afficher les points gagnés
                    _buildResultTile(
                      "Points",
                      "${resultData!.pointsEarned} / ${resultData!.totalPoints}",
                      color: Colors.amber,
                      icon: Icon(Icons.stars, color: Colors.white),
                    ),
                    
                    // Score final
                    _buildResultTile(
                      "Score Final",
                      resultData!.score.toString(),
                      color: notifire.getMainColor,
                      icon: Icon(FontAwesomeIcons.trophy, color: Colors.white, size: 20),
                    ),
                    
                    // ✅ NOUVEAU: Afficher le facteur temps
                    _buildResultTile(
                      "Facteur Temps",
                      "${resultData!.timeFactor.toStringAsFixed(2)}x",
                      color: Colors.blue,
                      icon: Icon(FontAwesomeIcons.clock, color: Colors.white, size: 20),
                    ),
                    
                    // ✅ NOUVEAU: Afficher réponses correctes/incorrectes
                    Row(
                      children: [
                        Expanded(
                          child: _buildResultTile(
                            "Correctes",
                            resultData!.correctCount.toString(),
                            color: Colors.green,
                            icon: Icon(Icons.check_circle, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildResultTile(
                            "Incorrectes",
                            resultData!.wrongCount.toString(),
                            color: Colors.red,
                            icon: Icon(Icons.cancel, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    
                    // Taux de réussite
                    _buildResultTile(
                      "Taux de réussite",
                      "${(resultData!.totalPoints > 0 ? (resultData!.pointsEarned / resultData!.totalPoints * 100) : resultData!.pourcentage).toStringAsFixed(1)}%",
                      color: Colors.purple,
                      icon: Icon(FontAwesomeIcons.chartPie, color: Colors.white, size: 20),
                    ),
                    
                    // Temps de réponse
                    _buildResultTile(
                      "Temps de réponse",
                      resultData!.timeRemaining,
                      color: Colors.orange,
                      icon: Icon(FontAwesomeIcons.hourglass, color: Colors.white, size: 20),
                    ),
                    
                    // ✅ NOUVEAU: Afficher le détail par question si disponible
                    if (resultData!.questions.isNotEmpty)
                      _buildQuestionsDetail(),
                  ],
                ),
              ),

              // Bouton pour retourner à l'accueil
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: CustomElevatedButton(
                  text: "Retourner à l'accueil",
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ NOUVEAU: Afficher le détail par question
  Widget _buildQuestionsDetail() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Détail des réponses",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: 10),
          ...resultData!.questions.asMap().entries.map((entry) {
            int index = entry.key + 1;
            QuestionResultDetail q = entry.value;
            return Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: q.isCorrect ? Colors.green : Colors.red,
                  width: 2,
                ),
                color: (q.isCorrect ? Colors.green : Colors.red).withAlpha(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        q.getResultEmoji(),
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Q$index: ${q.questionText}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "${q.pointsEarned} / ${q.pointsPossible} pts",
                        style: TextStyle(
                          color: q.isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildResultTile(
    String title,
    String value, {
    Color color = Colors.blue,
    Widget? icon,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 3, color: color),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: color),
            child: Row(
              children: [
                icon ?? Icon(Icons.info, color: Colors.white),
                SizedBox(width: 7),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
