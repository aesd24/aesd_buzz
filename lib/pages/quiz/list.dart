import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/models/quiz_model.dart';
import 'package:aesd/provider/quiz.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool _expandHistory = false; // State pour la section historique

  // controller de recherche
  final TextEditingController _searchController = TextEditingController();

  // Séparer les quiz joués et non-joués, puis trier par date
  Map<String, List<QuizModel>> _getGroupedAndSortedQuizzes() {
    List<QuizModel> availableQuizzes = [];
    List<QuizModel> playedQuizzes = [];

    for (var quiz in _quizzes) {
      if (_searchController.text.isEmpty ||
          quiz.title.toString().toLowerCase().contains(
            _searchController.text.toLowerCase(),
          )) {
        if (quiz.hasPlayed) {
          playedQuizzes.add(quiz);
        } else {
          availableQuizzes.add(quiz);
        }
      }
    }

    // Trier par date décroissante (récent d'abord)
    availableQuizzes.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
    playedQuizzes.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return {
      'available': availableQuizzes,
      'played': playedQuizzes,
    };
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
              _quizzes.clear();
              _quizzes.addAll(quizProvider.allQuizzes);

              final grouped = _getGroupedAndSortedQuizzes();
              final availableQuizzes = grouped['available'] ?? [];
              final playedQuizzes = grouped['played'] ?? [];

              if (quizProvider.allQuizzes.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async => await loadQuizzes(),
                  child: Center(
                    child: notFoundTile(text: "Aucun quiz disponible"),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => await loadQuizzes(),
                child: ListView(
                  children: [
                    // 📌 Section Quiz disponibles
                    if (availableQuizzes.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                          left: 16,
                        ),
                        child: Text(
                          'Quiz disponibles',
                          style:
                              Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: notifire.getMainText,
                                  ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: availableQuizzes.length,
                        itemBuilder: (context, index) {
                          return availableQuizzes[index].toTile(context);
                        },
                      ),
                    ],

                    // 📌 Section Historique (avec ExpansionTile)
                    if (playedQuizzes.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Theme(
                        data:
                            Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                        child: ExpansionTile(
                          initiallyExpanded: _expandHistory,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _expandHistory = expanded;
                            });
                          },
                          tilePadding: EdgeInsets.symmetric(horizontal: 16),
                          childrenPadding: EdgeInsets.zero,
                          title: Text(
                            'Historique des quiz',
                            style:
                                Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: notifire.getMainText,
                                    ),
                          ),
                          trailing: Icon(
                            _expandHistory
                                ? FontAwesomeIcons.chevronUp
                                : FontAwesomeIcons.chevronDown,
                            size: 14,
                            color: notifire.getMainText.withAlpha(150),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: playedQuizzes.length,
                              itemBuilder: (context, index) {
                                return playedQuizzes[index].toTile(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 📌 Si aucun quiz disponible
                    if (availableQuizzes.isEmpty && playedQuizzes.isEmpty)
                      Center(
                        child:
                            notFoundTile(
                              text: "Aucun quiz ne correspond à votre recherche",
                            ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
  }
}
