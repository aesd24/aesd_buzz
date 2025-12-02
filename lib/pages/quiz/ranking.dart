import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/not_found.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          results = value ?? [];
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
    if (_isLoading) {
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
              'Chargement du classement...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: notFoundTile(text: "Classement indisponible pour le moment..."),
      );
    }

    return RefreshIndicator(
      onRefresh: getRanking,
      color: Colors.purple.shade400,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Podium Top 3
          if (results.length >= 3) _buildPodium(),

          SizedBox(height: 24),

          // Titre classement général
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade50,
                  Colors.pink.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.rankingStar,
                  color: Colors.purple.shade600,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Classement Général',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: notifire.getMainText,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Liste complète
          ...results.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            return _buildRankingCard(player, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = results.take(3).toList();
    
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Titre podium
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.trophy,
                color: Colors.amber.shade600,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Top 3 du mois',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: notifire.getMainText,
                ),
              ),
            ],
          ),

          SizedBox(height: 32),

          // Podium
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2ème place
              if (top3.length > 1)
                Expanded(child: _buildPodiumPlace(top3[1], 2)),
              
              SizedBox(width: 8),

              // 1ère place
              if (top3.isNotEmpty)
                Expanded(child: _buildPodiumPlace(top3[0], 1)),
              
              SizedBox(width: 8),

              // 3ème place
              if (top3.length > 2)
                Expanded(child: _buildPodiumPlace(top3[2], 3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(dynamic player, int rank) {
    final colors = {
      1: [Colors.amber.shade400, Colors.amber.shade700],
      2: [Colors.grey.shade300, Colors.grey.shade500],
      3: [Colors.orange.shade300, Colors.orange.shade600],
    };

    final heights = {1: 140.0, 2: 110.0, 3: 110.0};

    return Column(
      children: [
        // Avatar et nom
        Text(
          player.buildWidget(context).toString().split(' ')[0], // Récupère le nom
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: rank == 1 ? 16 : 14,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8),

        // Container podium
        Container(
          height: heights[rank],
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors[rank]!,
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: colors[rank]![0].withOpacity(0.4),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône
              if (rank == 1)
                Icon(
                  FontAwesomeIcons.crown,
                  color: Colors.white,
                  size: 32,
                )
              else
                Text(
                  rank.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              
              SizedBox(height: 8),

              // Score
              Text(
                '2,${450 - (rank - 1) * 100}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: rank == 1 ? 18 : 16,
                ),
              ),
              Text(
                'pts',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingCard(dynamic player, int index) {
    final rank = index + 1;
    
    // Détermine la couleur selon le rang
    Color getRankColor() {
      if (rank == 1) return Colors.amber.shade400;
      if (rank == 2) return Colors.grey.shade400;
      if (rank == 3) return Colors.orange.shade400;
      return Colors.grey.shade300;
    }

    final isTopThree = rank <= 3;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isTopThree 
                ? getRankColor().withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigation vers profil si nécessaire
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Badge de rang
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isTopThree
                        ? LinearGradient(
                            colors: [
                              getRankColor(),
                              getRankColor().withOpacity(0.7),
                            ],
                          )
                        : null,
                    color: isTopThree ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isTopThree
                        ? Icon(
                            FontAwesomeIcons.trophy,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '#$rank',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                SizedBox(width: 16),

                // Informations joueur
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Joueur $rank', // À remplacer par player.name
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: notifire.getMainText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.solidStar,
                            color: Colors.amber.shade600,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '${2500 - (rank * 50)} points',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Indicateur de tendance
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: rank % 2 == 0
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.arrowTrendUp,
                        size: 12,
                        color: rank % 2 == 0
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                      ),
                      SizedBox(width: 4),
                      Text(
                        rank % 2 == 0 ? '+${rank}' : '-${rank}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: rank % 2 == 0
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}