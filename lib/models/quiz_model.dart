import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/pages/quiz/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class QuizModel {
  late int id;
  late String title;
  late String description;
  late DateTime createdAt;
  late DateTime expiryDate;
  late int questionCount;
  bool isAvailable = false;
  late bool hasPlayed;
  List questions = [];

  QuizModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['theme'];
    createdAt = DateTime.parse(json['created_at']);
    expiryDate = DateTime.parse(json['date']).add(Duration(days: 1));
    //description = json['description'];
    questions = json['questions'] ?? [];
    hasPlayed = json['has_played'] ?? false;
    questionCount = json['questions_count'] ?? json['questions'].length;
    isAvailable = DateTime.now().isBefore(expiryDate);
  }

  Widget buildModernCard(int index) {
    // Couleurs basées sur l'index pour varier les styles
    final gradients = [
      [Colors.purple.shade400, Colors.pink.shade400],
      [Colors.blue.shade400, Colors.cyan.shade400],
      [Colors.orange.shade400, Colors.red.shade400],
      [Colors.green.shade400, Colors.teal.shade400],
    ];
    final gradient = gradients[index % gradients.length];

    // Icônes variées basées sur l'index
    final icons = ['📖', '⛪', '✨', '🕊️', '📿', '⚡'];
    final icon = icons[index % icons.length];

    // Calcul simple de difficulté basé sur le nombre de questions
    String getDifficulty() {
      if (questionCount <= 15) return 'Facile';
      if (questionCount <= 25) return 'Moyen';
      return 'Difficile';
    }

    // Calcul du temps estimé basé sur le nombre de questions
    int getEstimatedTime() {
      return (questionCount * 0.5).ceil(); // ~30 secondes par question
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => QuizMainPage(quiz: this)),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Icon avec gradient
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: gradient[0].withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: notifire.getMainText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradient),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              getDifficulty(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildQuizStat(
                        FontAwesomeIcons.solidCircleQuestion,
                        '${questionCount} questions',
                        Colors.purple.shade400,
                      ),
                    ),
                    Expanded(
                      child: _buildQuizStat(
                        FontAwesomeIcons.clock,
                        '${getEstimatedTime()} min',
                        Colors.blue.shade400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuizStat(
                        FontAwesomeIcons.userGroup,
                        '${(index + 1) * 50 + 100} joueurs',
                        Colors.orange.shade400,
                      ),
                    ),
                    Expanded(
                      child: _buildQuizStat(
                        FontAwesomeIcons.award,
                        '${questionCount * 4} pts',
                        Colors.yellow.shade600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Bouton d'action
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withOpacity(0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: hasPlayed || !isAvailable
                          ? null
                          : () => Get.to(() => QuizMainPage(quiz: this)),
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              hasPlayed
                                  ? FontAwesomeIcons.check
                                  : FontAwesomeIcons.play,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              hasPlayed
                                  ? 'Terminé'
                                  : !isAvailable
                                  ? 'Non disponible'
                                  : 'Commencer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizStat(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  GestureDetector toTile(BuildContext context) => GestureDetector(
    onTap: () {
      Get.to(QuizMainPage(quiz: this));
    }, //=> Get.to(QuizMainPage(quiz: this)),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color:
            hasPlayed
                ? notifire.getMaingey.withAlpha(30)
                : notifire.getContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow:
            hasPlayed
                ? null
                : [
                  BoxShadow(
                    color: notifire.getMaingey.withAlpha(100),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color:
                hasPlayed
                    ? notifire.getMainText.withAlpha(100)
                    : notifire.getMainColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$questionCount Questions",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: hasPlayed ? notifire.getMaingey : null,
              ),
            ),
            Text(
              formatDate(createdAt, withTime: false),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: hasPlayed ? notifire.getMaingey : null,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
