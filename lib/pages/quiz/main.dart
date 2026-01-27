import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/pages/quiz/ranking.dart';
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
      setState(() => isLoading = true);
      await Provider.of<Quiz>(context, listen: false).getAny(widget.quiz.id);
      quiz = Provider.of<Quiz>(context, listen: false).selectedQuiz;
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Vérifiez votre connexion internet",
      );
    } catch (e) {
      print(e);
      MessageService.showErrorMessage("Une erreur inattendu s'est produite !");
    } finally {
      setState(() => isLoading = false);
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
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.purple.shade400),
        strokeWidth: 3,
      ),
      child: Scaffold(
        body: quiz == null
            ? Center(child: Text("Impossible de charger le quiz"))
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade50,
                      Colors.pink.shade50,
                      Colors.blue.shade50,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // AppBar moderne
                      _buildModernAppBar(),

                      // Contenu
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero Card
                              _buildHeroCard(),

                              SizedBox(height: 24),

                              // Informations du quiz
                              _buildQuizInfo(),

                              SizedBox(height: 24),

                              // Statistiques
                              _buildStatsGrid(),

                              SizedBox(height: 24),

                              // Bouton de classement
                              _buildRankingButton(),

                              SizedBox(height: 24),

                              // Warning
                              _buildWarning(),
                            ],
                          ),
                        ),
                      ),

                      // Bouton d'action fixe
                      _buildActionButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Bouton retour
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(12),
                child: Icon(
                  FontAwesomeIcons.arrowLeft,
                  size: 18,
                  color: notifire.getMainText,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Détails du Quiz',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: notifire.getMainText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.pink.shade400],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône et badge
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '📖',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: quiz!.isAvailable
                      ? Colors.green.shade400
                      : Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      quiz!.isAvailable
                          ? FontAwesomeIcons.check
                          : FontAwesomeIcons.clock,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      quiz!.isAvailable ? 'Disponible' : 'Expiré',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Titre
          Text(
            quiz!.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 12),

          // Dates
          Row(
            children: [
              Icon(
                FontAwesomeIcons.calendarDays,
                color: Colors.white.withOpacity(0.8),
                size: 14,
              ),
              SizedBox(width: 8),
              Text(
                "Créé le ${formatDate(quiz!.createdAt, withTime: false)}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(
                FontAwesomeIcons.clock,
                color: Colors.white.withOpacity(0.8),
                size: 14,
              ),
              SizedBox(width: 8),
              Text(
                "Expire le ${formatDate(quiz!.expiryDate, withTime: false)}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À propos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: notifire.getMainText,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            FontAwesomeIcons.solidCircleQuestion,
            'Questions',
            '${quiz!.questionCount} questions',
            Colors.purple.shade400,
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            FontAwesomeIcons.trophy,
            'Récompense',
            '${quiz!.questionCount * 4} points',
            Colors.amber.shade600,
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            quiz!.hasPlayed
                ? FontAwesomeIcons.check
                : FontAwesomeIcons.clock,
            'Statut',
            quiz!.hasPlayed ? 'Déjà participé' : 'Pas encore joué',
            quiz!.hasPlayed ? Colors.green.shade400 : Colors.orange.shade400,
          ),
          // Afficher les stats de l'utilisateur si disponibles
          if (quiz!.userScore != null) ...[
            SizedBox(height: 12),
            Divider(color: Colors.grey.shade200, height: 1),
            SizedBox(height: 12),
            Text(
              'Votre Score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: notifire.getMainText,
              ),
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              FontAwesomeIcons.star,
              'Votre score',
              '${quiz!.userScore} points',
              Colors.amber.shade600,
            ),
            if (quiz!.userTimeRemaining != null) ...[
              SizedBox(height: 12),
              _buildInfoRow(
                FontAwesomeIcons.hourglass,
                'Temps restant',
                quiz!.userTimeRemaining ?? 'N/A',
                Colors.blue.shade400,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: notifire.getMainText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: notifire.getMainText,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '🎯',
                'Précision',
                '85%',
                Colors.blue.shade400,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '⚡',
                'Rapidité',
                'Moyen',
                Colors.orange.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 32)),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: notifire.getMainText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade500],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * .75,
              decoration: BoxDecoration(
                color: notifire.getbgcolor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(FontAwesomeIcons.xmark),
                        ),
                        Expanded(
                          child: Text(
                            "Classement",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: QuizRankingPage(
                      dataLoader: () => Provider.of<Quiz>(
                        context,
                        listen: false,
                      ).getQuizRanking(quiz!.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.crown,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Voir le classement',
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
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.circleExclamation,
            color: Colors.red.shade600,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Une fois ouvert, vous devrez terminer le quiz avant de quitter la page.",
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final canStart = !quiz!.hasPlayed && quiz!.isAvailable;
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: canStart
                ? LinearGradient(
                    colors: [Colors.purple.shade400, Colors.pink.shade400],
                  )
                : null,
            color: canStart ? null : notifire.getMaingey,
            borderRadius: BorderRadius.circular(16),
            boxShadow: canStart
                ? [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canStart ? () => _showStartQuizWarning() : null,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      canStart
                          ? FontAwesomeIcons.play
                          : FontAwesomeIcons.lock,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      canStart
                          ? 'Commencer le Quiz'
                          : quiz!.hasPlayed
                              ? 'Déjà participé'
                              : 'Quiz non disponible',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showStartQuizWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                FontAwesomeIcons.exclamation,
                color: Colors.orange.shade600,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Avertissement',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Une fois que vous aurez démarré ce quiz:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 12),
              _buildWarningPoint('Vous ne pourrez plus quitter sans terminer le quiz'),
              SizedBox(height: 8),
              _buildWarningPoint('Le temps de quiz commencera à s\'écouler'),
              SizedBox(height: 8),
              _buildWarningPoint('Vous devez completer l\'ensemble des questions'),
              SizedBox(height: 20),
              Text(
                'Êtes-vous sûr(e) de vouloir continuer?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: ButtonStyle(
                overlayColor: WidgetStatePropertyAll(Colors.grey.shade100),
              ),
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.to(() => AnswerPage(quiz: quiz!));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continuer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWarningPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(
            FontAwesomeIcons.circleXmark,
            size: 16,
            color: Colors.red.shade400,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
