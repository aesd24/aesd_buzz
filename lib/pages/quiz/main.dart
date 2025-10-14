import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/pages/quiz/correction.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/provider/quiz.dart';
import 'package:aesd/services/message.dart';
import 'package:aesd/models/quiz_model.dart';
import 'package:aesd/pages/quiz/answer.dart';
import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class QuizMainPage extends StatefulWidget {
  const QuizMainPage({super.key, required this.quiz});

  final QuizModel quiz;

  @override
  State<QuizMainPage> createState() => _QuizMainPageState();
}

class _QuizMainPageState extends State<QuizMainPage> {
  bool isLoading = false;
  QuizModel? quiz;

  Future<void> loadQuiz() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Quiz>(context, listen: false).getAny(widget.quiz.id);
      quiz = Provider.of<Quiz>(context, listen: false).selectedQuiz;
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Vérifiez votre connexion internet",
      );
    } /*catch(e) {
      print(e);
      MessageService.showErrorMessage("Une erreur inattendu s'est produite !");
    }*/ finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: AppBar(),
        body:
            quiz == null
                ? Center(child: Text("Impossible de charger le quiz"))
                : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            if (!quiz!.isAvailable)
                              CustomTextButton(
                                onPressed:
                                    () => MessageService.showInfoMessage(
                                      "Bientôt disponible...",
                                    ),
                                /*() => Get.to(
                                      QuizCorrectResponses(quizId: quiz!.id),
                                    )*/
                                label: "Afficher les bonnes reponses",
                              ),

                            CustomTextButton(
                              onPressed:
                                  () => MessageService.showInfoMessage(
                                    "Bientôt disponible...",
                                  ),
                              label: "Classement",
                              type: ButtonType.info.copyWith(
                                icon: cusFaIcon(
                                  FontAwesomeIcons.crown,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          quiz!.title,
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "Du ${formatDate(quiz!.createdAt, withTime: false)}",
                      ),
                      Text(
                        "Expire le ${formatDate(quiz!.expiryDate, withTime: false)}",
                      ),
                      SizedBox(height: 20),
                      parametersTile(
                        context,
                        label: "Nombre de questions",
                        value: quiz!.questionCount,
                      ),
                      // parametersTile(context, label: "J'ai participé", value: "Non"),
                      // parametersTile(context, label: "Mon score", value: "--"),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: CustomElevatedButton(
                          color:
                              (quiz!.hasPlayed || !quiz!.isAvailable)
                                  ? notifire.getMaingey
                                  : null,
                          text: "Commencer",
                          onPressed:
                              (quiz!.hasPlayed || !quiz!.isAvailable)
                                  ? null
                                  : () => Get.to(AnswerPage(quiz: quiz!)),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          "Une fois ouvert, vous devrez terminer"
                          " le quiz avant de quitter la page.",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget parametersTile(
    BuildContext context, {
    required String label,
    required dynamic value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          Text(
            value.toString(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
