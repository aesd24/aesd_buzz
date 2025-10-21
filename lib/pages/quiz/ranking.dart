import 'package:aesd/components/not_found.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizRankingPage extends StatefulWidget {
  const QuizRankingPage({super.key, required this.dataLoader});

  final Future Function() dataLoader;

  @override
  State<QuizRankingPage> createState() => _QuizRankingPageState();
}

class _QuizRankingPageState extends State<QuizRankingPage> {
  bool _isLoading = false;
  List results = [];

  Future getRanking() async {
    try {
      setState(() => _isLoading = true);
      await widget.dataLoader().then((value) {
        setState(() {
          results = value;
        });
      });
    } catch (e) {
      results = [];
      e.printError();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getRanking();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator());

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child:
          results.isEmpty
              ? notFoundTile(text: "Classement indisponible pour le moment...")
              : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final current = results[index];
                  return current.buildWidget(context);
                },
              ),
    );
  }
}
