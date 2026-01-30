import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/models/quiz_model.dart';
import 'package:aesd/models/ranking.dart';
import 'package:aesd/pages/quiz/ranking.dart';
import 'package:aesd/provider/auth.dart';
import 'package:aesd/provider/quiz.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class QuizHome extends StatefulWidget {
  const QuizHome({super.key});

  @override
  State<QuizHome> createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingQuizzes = false;
  List<RankingModel> _monthRanking = [];
  bool _expandHistory = false; // État pour la section historique

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    if (!mounted) return;
    setState(() => _isLoadingQuizzes = true);
    try {
      final quizProvider = Provider.of<Quiz>(context, listen: false);
      await quizProvider.getAll();
      try {
        final ranking = await quizProvider.getMonthRanking();
        if (mounted) setState(() => _monthRanking = ranking);
      } catch (_) {
        if (mounted) setState(() => _monthRanking = []);
      }
    } catch (e) {
      print('Erreur lors du chargement des quiz: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingQuizzes = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          // Header avec style moderne
          _buildModernHeader(),

          // Tabs personnalisés
          _buildCustomTabs(),

          // Contenu des tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuizList(),
                QuizRankingPage(
                  dataLoader: Provider.of<Quiz>(context, listen: false).getMonthRanking,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          // Icon moderne avec gradient
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.pink.shade400],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              FontAwesomeIcons.trophy,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.purple.shade600, Colors.pink.shade600],
                  ).createShader(bounds),
                  child: Text(
                    'Quiz Biblique',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Testez vos connaissances !',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.pink.shade400],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🎮'),
                SizedBox(width: 8),
                Text('Jeux'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🏆'),
                SizedBox(width: 8),
                Text('Classement'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizList() {
    // Afficher le loader pendant le chargement initial
    if (_isLoadingQuizzes) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.purple.shade400),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des quiz...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Consumer<Quiz>(
      builder: (context, quizProvider, child) {
        if (quizProvider.allQuizzes.isEmpty) {
          return Center(
            child: notFoundTile(text: "Aucun quiz disponible"),
          );
        }

        // Séparer et trier les quiz
        final grouped = _getGroupedAndSortedQuizzes(quizProvider.allQuizzes);
        final availableQuizzes = grouped['available'] ?? [];
        final playedQuizzes = grouped['played'] ?? [];

        return Column(
          children: [


            // Liste des quiz
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadQuizzes,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Stats Cards déplacés ici pour scroller avec le contenu
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildStatsCards(quizProvider),
                    ),

                    // Section Quiz disponibles
                    if (availableQuizzes.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          'Quiz disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: notifire.getMainText,
                          ),
                        ),
                      ),
                      ...availableQuizzes.asMap().entries.map((entry) {
                        return entry.value.buildModernCard(entry.key);
                      }).toList(),
                    ],

                    // Section Historique (repliable)
                    if (playedQuizzes.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: _expandHistory,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _expandHistory = expanded;
                            });
                          },
                          tilePadding: EdgeInsets.symmetric(horizontal: 0),
                          childrenPadding: EdgeInsets.zero,
                          title: Text(
                            'Historique des quiz',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: notifire.getMainText,
                            ),
                          ),
                          trailing: Icon(
                            _expandHistory
                                ? FontAwesomeIcons.chevronUp
                                : FontAwesomeIcons.chevronDown,
                            size: 16,
                            color: notifire.getMainText.withAlpha(150),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          children: [
                            ...playedQuizzes.asMap().entries.map((entry) {
                              return entry.value.buildModernCard(entry.key);
                            }).toList(),
                          ],
                        ),
                      ),
                    ],

                    // Si aucun quiz disponible
                    if (availableQuizzes.isEmpty && playedQuizzes.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: notFoundTile(text: "Aucun quiz disponible"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCards(Quiz quizProvider) {
    final currentUserId = Provider.of<Auth>(context, listen: false).user?.id;
    int? userRank;
    int userTotalScore = 0;
    if (currentUserId != null && _monthRanking.isNotEmpty) {
      final uid = currentUserId;
      final pos = _monthRanking.indexWhere((r) => r.userId == uid);
      if (pos >= 0) {
        userRank = pos + 1;
        userTotalScore = _monthRanking[pos].score;
      }
    }
    final scoreText = userTotalScore > 0 ? _formatScore(userTotalScore) : '-';
    final rankText = userRank != null ? '#$userRank' : '-';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: FontAwesomeIcons.bullseye,
              label: 'Complétés',
              value: '${quizProvider.allQuizzes.where((q) => q.hasPlayed).length}',
              gradient: [Colors.blue.shade400, Colors.cyan.shade400],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: FontAwesomeIcons.bolt,
              label: 'Score Total',
              value: scoreText,
              gradient: [Colors.orange.shade400, Colors.red.shade400],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: FontAwesomeIcons.trophy,
              label: 'Rang',
              value: rankText,
              gradient: [Colors.green.shade400, Colors.teal.shade400],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatScore(int score) {
    if (score >= 1000000) return '${(score / 1000000).toStringAsFixed(1)}M';
    if (score >= 1000) return '${(score / 1000).toStringAsFixed(1)}k';
    return score.toString();
  }

  /// Sépare les quiz joués et non joués, puis les trie par date (plus récent d'abord)
  Map<String, List<QuizModel>> _getGroupedAndSortedQuizzes(List<QuizModel> allQuizzes) {
    List<QuizModel> availableQuizzes = [];
    List<QuizModel> playedQuizzes = [];

    for (var quiz in allQuizzes) {
      if (quiz.hasPlayed) {
        playedQuizzes.add(quiz);
      } else {
        availableQuizzes.add(quiz);
      }
    }

    // Trier par date décroissante (plus récent d'abord)
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: notifire.getMainText,
            ),
          ),
        ],
      ),
    );
  }
}