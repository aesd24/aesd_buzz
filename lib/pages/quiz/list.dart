import 'dart:io';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/models/quiz_model.dart';
import 'package:aesd/provider/quiz.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class QuizzesList extends StatefulWidget {
  const QuizzesList({super.key});

  @override
  State<QuizzesList> createState() => _QuizzesListState();
}

class _QuizzesListState extends State<QuizzesList> {
  bool isLoading = false;
  final List<QuizModel> _quizzes = [];

  // controller de recherche
  final TextEditingController _searchController = TextEditingController();
  List quizFilter() {
    if (_searchController.text.isEmpty) {
      return _quizzes;
    } else {
      List returned = [];
      for (var element in _quizzes) {
        if (element.title.toString().toLowerCase().contains(
          _searchController.text.toLowerCase(),
        )) {
          returned.add(element);
        }
      }
      return returned;
    }
  }

  Future<void> loadQuizzes() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Quiz>(context, listen: false).getAll();
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Vérifiez votre connexion internet",
      );
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu s'est produite !");
      e.printError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? ListShimmerPlaceholder()
        : Padding(
          padding: const EdgeInsets.all(10),
          child: Consumer<Quiz>(
            builder: (context, quizProvider, child) {
              return RefreshIndicator(
                onRefresh: () async => await loadQuizzes(),
                child:
                    quizProvider.allQuizzes.isNotEmpty
                        ? ListView.builder(
                          itemCount: quizProvider.allQuizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = quizProvider.allQuizzes[index];
                            return quiz.toTile(context);
                          },
                        )
                        : Center(
                          child: notFoundTile(text: "Aucun quiz disponible"),
                        ),
              );
            },
          ),
        );
  }
}
