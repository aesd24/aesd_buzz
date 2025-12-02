import 'dart:async';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/modal.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/models/question_model.dart';
import 'package:aesd/models/quiz_model.dart';
import 'package:aesd/pages/quiz/result.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AnswerPage extends StatefulWidget {
  const AnswerPage({super.key, required this.quiz});

  final QuizModel quiz;

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  Duration timeLeft = Duration(seconds: 0);
  int questionIndex = 0;
  late QuestionModel currentQuestion;
  Map<String, List<int>> playerAnswers = {};
  bool isFinish = false;
  late Timer _timer;
  List<int> choices = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          timeLeft = timeLeft + Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
    _updateCurrentQuestion();
  }

  void _updateCurrentQuestion() {
    currentQuestion = QuestionModel.fromJson(
      widget.quiz.questions[questionIndex],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Avec PopScope, la logique de confirmation se déplace vers onPopInvoked
  // canPop détermine si le pop est possible *avant* la tentative.
  void _handlePopAttempt(bool didPop, dynamic result) {
    if (!didPop && !isFinish) {
      showModal(
        context: context,
        dialog: CustomAlertDialog(
          title: "Désolé",
          content: "Vous devez d'abord terminer le quiz avant de quitter",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Utilisez PopScope ici
      canPop:
          isFinish, // L'utilisateur ne peut quitter que si le quiz est terminé
      onPopInvokedWithResult: _handlePopAttempt, // Gérer la tentative de pop
      child: Scaffold(
        appBar: AppBar(
          leading: customBackButton(),
          title: Text(
            widget.quiz.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  cusFaIcon(FontAwesomeIcons.clock),
                  SizedBox(width: 5),
                  Text(getTimeInString(timeLeft)),
                ],
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (questionIndex + 1) / widget.quiz.questionCount,
                    minHeight: 3,
                    backgroundColor: notifire.getMaingey,
                    valueColor: AlwaysStoppedAnimation(notifire.getMainColor),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      "Question ${questionIndex + 1} sur ${widget.quiz.questionCount}",
                    ),
                  ),
                ),

                SizedBox(height: 30),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      currentQuestion.label,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Column(
                  children: List.generate(currentQuestion.options.length, (
                    index,
                  ) {
                    final current = currentQuestion.options[index];
                    return current.toTile(
                      value: current.id,
                      title: current.label,
                      groupValue: choices,
                      onChange: (value) {
                        setState(() {
                          if (choices.contains(value)) {
                            choices.remove(value);
                          } else {
                            choices.add(value);
                          }
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    if (questionIndex > 0) ...[
                      IconButton(
                        onPressed: () {
                          setState(() {
                            questionIndex--;
                            _updateCurrentQuestion();
                            choices =
                                playerAnswers[currentQuestion.id.toString()] ??
                                [];
                          });
                        },
                        icon: cusFaIcon(FontAwesomeIcons.arrowLeft),
                      ),
                      SizedBox(width: 30),
                    ],
                    Expanded(
                      child: CustomElevatedButton(
                        onPressed: () {
                          if (choices.isNotEmpty) {
                            playerAnswers[currentQuestion.id.toString()] =
                                choices;

                            if (questionIndex <
                                widget.quiz.questions.length - 1) {
                              setState(() {
                                questionIndex++;
                                _updateCurrentQuestion();
                                choices =
                                    playerAnswers[questionIndex.toString()] ??
                                    [];
                              });
                            } else {
                              setState(() {
                                isFinish =
                                    true; // IMPORTANT : Mettre à jour isFinish
                              });
                              _timer.cancel();
                              // canPop deviendra true, permettant la navigation vers la page suivante
                              // sans que _handlePopAttempt n'intervienne pour bloquer.
                              Get.off(
                                () => QuizResultPage(
                                  quizId: widget.quiz.id,
                                  answers: playerAnswers,
                                  timeElapse: timeLeft,
                                ),
                              );
                            }
                          } else {
                            MessageService.showWarningMessage(
                              "Choisissez d'abord une option",
                            );
                          }
                        },
                        text: "Suivant",
                        icon: cusFaIcon(
                          FontAwesomeIcons.arrowRight,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
