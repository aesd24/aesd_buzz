import 'dart:async';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/models/question_model.dart';
import 'package:aesd/models/quiz_model.dart';
import 'package:aesd/pages/quiz/result.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AnswerPage extends StatefulWidget {
  AnswerPage({super.key, required this.quiz});

  QuizModel quiz;

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  Duration timeLeft = Duration(seconds: 0);

  // gestion du quiz
  int questionIndex = 0;
  late QuestionModel currentQuestion;
  Map<String, List<int>> playerAnswers = {};

  bool isFinish = false;
  late Timer _timer;
  List<int> choices = [];

  @override
  void initState() {
    super.initState();
    // Incrémenter le temps à chaque seconde écoulé
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft = timeLeft + Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      currentQuestion = QuestionModel.fromJson(
        widget.quiz.questions[questionIndex],
      );
    });
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(vertical: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getTimeInString(timeLeft)),
                    Text(
                      "Question ${questionIndex + 1}/${widget.quiz.questions.length}",
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context) {
                  final options = currentQuestion.options;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            currentQuestion.label,
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: List.generate(options.length, (index) {
                            var current = options[index];
                            return current.toTile(
                              title: current.label,
                              value: current.id,
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
                      ),
                      const SizedBox(height: 30),
                      CustomElevatedButton(
                        onPressed: () {
                          if (choices.isNotEmpty) {
                            // Enregistrer la reponse du joueur.
                            playerAnswers[currentQuestion.id.toString()] =
                                choices;

                            // passez à la question suivante ou terminer le quiz
                            if (questionIndex <
                                widget.quiz.questions.length - 1) {
                              setState(() {
                                questionIndex++;
                              });
                              choices = [];
                            } else {
                              isFinish = true;
                              Get.replace(
                                QuizResultPage(
                                  quizId: widget.quiz.id,
                                  answers: playerAnswers,
                                  timeElapse: timeLeft,
                                ),
                              );
                            }
                          } else {
                            MessageService.showWarningMessage("Choisissez d'abord une option");
                          }
                        },
                        text: "Suivant",
                        icon: FaIcon(
                          FontAwesomeIcons.arrowRight,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
