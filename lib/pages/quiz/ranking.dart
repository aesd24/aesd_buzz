import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/models/ranking.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
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
  List<RankingModel> results = [];

  Future getRanking() async {
    try {
      setState(() => _isLoading = true);
      await widget.dataLoader().then((value) {
        setState(() {
          results = value != null ? List<RankingModel>.from(value as List) : [];
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

          // Liste complète - utilise directement buildWidget du modèle
          ...results.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            return _buildModernRankingCard(player, index + 1);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = results.take(3).toList();
    final colors = [Colors.amber, Colors.grey, Colors.orange];
    final emojis = ['🥇', '🥈', '🥉'];
    final order = [1, 0, 2]; // 2e, 1er, 3e

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < order.length; i++) ...[
                if (i > 0) SizedBox(width: 8),
                if (order[i] < top3.length)
                  Expanded(
                    child: _buildPodiumPlace(
                      order[i] + 1,
                      top3[order[i]],
                      emojis[order[i]],
                      colors[order[i]],
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(int rank, RankingModel player, String emoji, Color color) {
    final heights = {1: 140.0, 2: 110.0, 3: 110.0};

    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: rank == 1 ? 60 : 50)),
        SizedBox(height: 8),
        Text(
          player.userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: rank == 1 ? 14 : 12,
            color: notifire.getMainText,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8),
        Container(
          height: heights[rank] ?? 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.shade400,
                color.shade700,
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rank == 1)
                Icon(FontAwesomeIcons.crown, color: Colors.white, size: 32)
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
              Text(
                '${player.score}',
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

  Widget _buildModernRankingCard(RankingModel player, int rank) {
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
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: player.userPicUrl.isNotEmpty
                      ? FastCachedImageProvider(player.userPicUrl)
                      : null,
                  child: player.userPicUrl.isEmpty
                      ? Text(
                          player.userName.isNotEmpty
                              ? player.userName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: notifire.getMainText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                            '${player.score} points',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          if (player.timeElapsed != null) ...[
                            SizedBox(width: 8),
                            Icon(FontAwesomeIcons.clock, size: 12, color: Colors.grey.shade600),
                            SizedBox(width: 4),
                            Text(
                              player.timeElapsed!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
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