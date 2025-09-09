import 'dart:io';
import 'package:aesd/components/buttons.dart';
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
    required this.timeElapse
  });

  final int quizId;
  final Map<String, List<int>> answers;
  final Duration timeElapse;

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  String text = "Envoi des réponses";
  IconData icon = FontAwesomeIcons.spinner;
  Color color = Colors.black54;
  bool success = false;
  bool isLoading = false;

  sendResponses() async {
    try {
      setState(() => isLoading = true);
      await Provider.of<Quiz>(context, listen: false).sendResponses(
        widget.quizId,
        answers: widget.answers,
        timeElapsed: getTimeInString(widget.timeElapse)
      );
      setState(() {
        text = "Vos réponses ont été envoyées";
        icon = FontAwesomeIcons.circleCheck;
        color = Colors.green;
        success = true;
      });
    } on HttpException catch (e) {
      setState(() {
        text = e.message;
        icon = FontAwesomeIcons.planeCircleXmark;
        color = Colors.red;
        success = false;
      });
    } on DioException catch(e) {
      setState(() {
        text = "Erreur réseau. Vérifiez votre connexion internet";
        icon = FontAwesomeIcons.roadCircleXmark;
        color = Colors.red;
        success = false;
      });
      e.printError();
    } catch (e) {
      setState(() {
        text = "Oups... Quelque chose s'est mal passé";
        icon = FontAwesomeIcons.plugCircleXmark;
        color = Colors.red;
        success = false;
      });
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: isLoading ? CircularProgressIndicator(
            strokeWidth: 1.5,
          ) :
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon,
                color: color,
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                text,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: CustomElevatedButton(
                  text: success ? "Retour" : "Rééssayer",
                  onPressed: success ? () => Get.back() : sendResponses
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
