import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/functions/formatteurs.dart';
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
  final resultData = {};

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
              resultData['score'] = value['score'];
              resultData['time_remaining'] = value['time_remaining'];
              resultData['success_rate'] = value['pourcentage'];
              isSucceeded = true;
            });
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
    if (!isSucceeded) {
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
                        "Quiz terminée !",
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(color: notifire.getMainColor),
                      ),
                    ),
                  ],
                ),
              ),

              // Afficher les résultats
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildResultTile(
                      "Points obtenus",
                      resultData['score'].toString(),
                    ),
                    _buildResultTile(
                      "Taux de réussite",
                      "${resultData["success_rate"]}%",
                      color: Colors.purple,
                      icon: getIcon('rate.png'),
                    ),
                    _buildResultTile(
                      "Temps de réponse",
                      resultData["time_remaining"],
                      color: Colors.red,
                      icon: getIcon('clock.png'),
                    ),
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
                icon ?? getIcon("target.png"),
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
              ).textTheme.labelLarge!.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Image getIcon(String imageName) {
    return Image.asset(
      "assets/icons/$imageName",
      fit: BoxFit.cover,
      width: 20,
      height: 20,
    );
  }
}
