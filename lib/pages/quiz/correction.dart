import 'package:aesd/components/buttons.dart';
import 'package:aesd/provider/quiz.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class QuizCorrectResponses extends StatefulWidget {
  const QuizCorrectResponses({super.key, required this.quizId});

  final int quizId;

  @override
  State<QuizCorrectResponses> createState() => _QuizCorrectResponsesState();
}

class _QuizCorrectResponsesState extends State<QuizCorrectResponses> {
  bool isLoading = false;

  Future getCorrectResponses() async {
    try {
      setState(() => isLoading = true);
      await Provider.of<Quiz>(
        context,
        listen: false
      ).getCorrectAnswers(widget.quizId);
    } catch (e) {
      e.printError();
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getCorrectResponses();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: customBackButton(),
        title: Text("Bonne réponses"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(child: Column(children: [])),
      ),
    );
  }
}
