import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/components/structure.dart';
import 'package:aesd/services/message.dart';
import 'package:aesd/provider/forum.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ForumMain extends StatefulWidget {
  const ForumMain({super.key});

  @override
  State<ForumMain> createState() => _ForumMainState();
}

class _ForumMainState extends State<ForumMain> {
  bool isLoading = false;

  Future<void> loadSubjects() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Forum>(context, listen: false).getAll();
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Vérifiez votre connexion internet",
      );
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu s'est produite !");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    loadSubjects();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F5E9), // Vert très clair
            Colors.white,
            Color(0xFFF1F8E9), // Vert-jaune très clair
          ],
        ),
      ),
      child: Column(
        children: [
          // Header moderne
          _buildModernHeader(),

          // Contenu
          Expanded(
            child: isLoading
                ? ListShimmerPlaceholder()
                : Consumer<Forum>(
                    builder: (context, forum, child) {
                      if (forum.subjects.isEmpty) {
                        return Center(
                          child: notFoundTile(
                            text: "Aucun sujet de discussion disponible",
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: loadSubjects,
                        color: Color(0xFF43A047),
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: forum.subjects.length,
                          itemBuilder: (context, index) {
                            var subject = forum.subjects[index];
                            // Utiliser la méthode toTile du modèle qui retourne le Widget avec navigation
                            return subject.toTile(context);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          // Icône moderne
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2E7D32).withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              FontAwesomeIcons.comments,
              color: Colors.white,
              size: 22,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  ).createShader(bounds),
                  child: Text(
                    'Forum',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Partagez et discutez',
                  style: TextStyle(
                    color: Color(0xFF5D4037),
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
}