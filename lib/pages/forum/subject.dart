import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/pages/social/create_form.dart';
import 'package:aesd/provider/forum.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DiscutionSubjectPage extends StatefulWidget {
  const DiscutionSubjectPage({super.key});

  @override
  State<DiscutionSubjectPage> createState() => _DiscutionSubjectPageState();
}

class _DiscutionSubjectPageState extends State<DiscutionSubjectPage> {
  bool _isLoading = true;
  bool _likeLoading = false;
  bool _isExpanded = false;
  bool _showFullContext = false;
  int? subjectId;

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> loadSubject(int id) async {
    try {
      await Provider.of<Forum>(context, listen: false).getAny(id);
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Verifiez votre connexion et réessayez",
      );
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu est survenue");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> likeSubject(int id) async {
    try {
      setState(() {
        _likeLoading = true;
      });
      await Provider.of<Forum>(
        context,
        listen: false,
      ).likeSubject(subjectId: id);
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Verifiez votre connexion et réessayez",
      );
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu est survenue");
    } finally {
      setState(() {
        _likeLoading = false;
      });
    }
  }

  Future makeComment(int id, String comment) async {
    try {
      setState(() {
        _isLoading = true;
      });
      bool result = await Provider.of<Forum>(
        context,
        listen: false,
      ).makeComment(subjectId: id, comment: comment);
      if (result) {
        await Provider.of<Forum>(context, listen: false).getAny(id);
        MessageService.showSuccessMessage("Votre commentaire a été envoyé !");
        Get.back();
      }
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Vérifiez votre connexion internet et réessayez",
      );
    } catch (e) {
      print('Erreur: $e');
      MessageService.showErrorMessage("Une erreur inattendu est survenue.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      subjectId = Get.arguments['id'] as int;
      await loadSubject(subjectId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF43A047)),
                strokeWidth: 3,
              ),
            ),
          )
        : Consumer<Forum>(
            builder: (context, provider, child) {
              if (provider.selectedSubject == null) {
                return Scaffold(
                  body: Center(
                    child: notFoundTile(
                      icon: FontAwesomeIcons.personCircleExclamation,
                      text: "Impossible de récupérer le sujet",
                    ),
                  ),
                );
              }
              final subject = provider.selectedSubject!;
              final bool isClosed = subject.isClosed ?? false;

              return Scaffold(
                backgroundColor: Color(0xFFF5F5F5),
                body: RefreshIndicator(
                  onRefresh: () async {
                    await loadSubject(subjectId!);
                  },
                  color: Color(0xFF43A047),
                  child: CustomScrollView(
                    slivers: [
                      // AppBar moderne avec image réduite
                      SliverAppBar(
                        expandedHeight: 200, // Réduit de 280 à 200
                        pinned: true,
                        backgroundColor: Color(0xFF1B5E20),
                        leading: Padding(
                          padding: EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: customBackButton(color: Colors.white),
                          ),
                        ),
                        actions: [
                          // Badge de statut
                          Container(
                            margin: EdgeInsets.only(right: 16, top: 12),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isClosed
                                  ? Color(0xFF6D4C41)
                                  : Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  isClosed ? 'Fermé' : 'Ouvert',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          title: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              subject.title ?? 'Sans titre',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Image de fond
                              Image.asset(
                                "assets/images/bg_forum.png",
                                fit: BoxFit.cover,
                              ),
                              // Overlay gradient
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF1B5E20).withOpacity(0.7),
                                      Color(0xFF2E7D32).withOpacity(0.9),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Contexte de la discussion avec "Voir plus"
                      SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF2E7D32).withOpacity(0.1),
                                blurRadius: 15,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // En-tête du contexte
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF2E7D32),
                                          Color(0xFF66BB6A),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.bookOpen,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Contexte de la discussion",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1B5E20),
                                          ),
                                        ),
                                        Text(
                                          formatDate(subject.createdAt, withTime: false),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF5D4037).withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16),

                              // Corps du message avec limite de mots
                              _buildContextBody(subject.body ?? ''),

                              SizedBox(height: 16),

                              // Stats en bas du contexte
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.message,
                                      size: 14,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '${subject.comments?.length ?? 0} réponses',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Icon(
                                      FontAwesomeIcons.heart,
                                      size: 14,
                                      color: Color(0xFF6D4C41),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '${subject.likes ?? 0} j\'aime',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6D4C41),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Titre de section commentaires
                      if (subject.comments != null && subject.comments.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: Text(
                              'Commentaires (${subject.comments.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                        ),

                      // Liste des commentaires stylés
                      subject.comments != null && subject.comments.isNotEmpty
                          ? SliverList.builder(
                              itemCount: subject.comments.length,
                              itemBuilder: (context, index) =>
                                  _buildModernComment(subject.comments[index], context),
                            )
                          : SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.commentSlash,
                                      size: 48,
                                      color: Color(0xFF5D4037).withOpacity(0.3),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Aucun commentaire pour le moment",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF5D4037).withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                      SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
                floatingActionButton: !isClosed
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_isExpanded) ...[
                            // Bouton Like
                            Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF6D4C41), Color(0xFF8D6E63)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF6D4C41).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async => await likeSubject(subject.id),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _likeLoading
                                              ? SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(Colors.white),
                                                  ),
                                                )
                                              : Icon(
                                                  subject.isLiked
                                                      ? FontAwesomeIcons.solidHeart
                                                      : FontAwesomeIcons.heart,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                          SizedBox(width: 8),
                                          Text(
                                            '${subject.likes ?? 0}',
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
                            ),

                            // Bouton Commenter
                            Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF388E3C), Color(0xFF66BB6A)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF388E3C).withOpacity(0.3),
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
                                      builder: (context) => CreatePost(
                                        onSubmit: (comment) =>
                                            makeComment(subject.id, comment.content),
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Icon(
                                      FontAwesomeIcons.solidComment,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // Bouton principal toggle
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF2E7D32).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _toggle,
                                borderRadius: BorderRadius.circular(16),
                                child: Icon(
                                  _isExpanded
                                      ? FontAwesomeIcons.xmark
                                      : FontAwesomeIcons.plus,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              );
            },
          );
  }

  // Widget pour le corps du contexte avec limite de mots
  Widget _buildContextBody(String body) {
    final words = body.split(' ');
    final int wordLimit = 50; // Limite de 50 mots
    final bool needsTruncate = words.length > wordLimit;
    
    String displayText = _showFullContext || !needsTruncate
        ? body
        : words.take(wordLimit).join(' ') + '...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF5D4037),
            height: 1.6,
          ),
        ),
        if (needsTruncate)
          TextButton(
            onPressed: () {
              setState(() {
                _showFullContext = !_showFullContext;
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _showFullContext ? 'Voir moins' : 'Voir plus',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  // Widget stylisé pour les commentaires
  Widget _buildModernComment(dynamic comment, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF2E7D32).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: comment.getWidget(context),
    );
  }
}