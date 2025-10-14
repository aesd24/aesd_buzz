import 'package:aesd/components/not_found.dart';
import 'package:flutter/material.dart';

class QuizRankingPage extends StatefulWidget {
  const QuizRankingPage({super.key});

  @override
  State<QuizRankingPage> createState() => _QuizRankingPageState();
}

class _QuizRankingPageState extends State<QuizRankingPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: notFoundTile(text: "Classement indisponible pour le moment..."),
    );
  }
}
