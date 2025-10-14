import 'package:aesd/pages/quiz/list.dart';
import 'package:aesd/pages/quiz/ranking.dart';
import 'package:flutter/material.dart';

class QuizHome extends StatefulWidget {
  const QuizHome({super.key});

  @override
  State<QuizHome> createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TabBar(
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              tabs: [Tab(text: "Jeux disponibles"), Tab(text: "Classement")],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  QuizzesList(),
                  QuizRankingPage(),
                ]
              ),
            )
          ],
        ),
      ),
    );
  }
}
