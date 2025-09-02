import 'dart:io';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/components/structure.dart';
import 'package:aesd/pages/testimony/create.dart';
import 'package:aesd/provider/testimony.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class TestimoniesList extends StatefulWidget {
  const TestimoniesList({super.key});

  @override
  State<TestimoniesList> createState() => _TestimoniesListState();
}

class _TestimoniesListState extends State<TestimoniesList> {
  bool isLoading = false;
  Future getTestimonies() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Testimony>(context, listen: false).getAll();
    } on HttpException {
      MessageService.showErrorMessage("L'opération à échoué !");
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu est survenue !");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getTestimonies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child:
                  isLoading
                      ? ListShimmerPlaceholder()
                      : Consumer<Testimony>(
                        builder: (context, provider, child) {
                          if (provider.testimonies.isEmpty) {
                            return notFoundTile(
                              text: "Aucun témoignage trouvé pour le moment",
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () async => await getTestimonies(),
                            child: ListView.builder(
                              itemCount: provider.testimonies.length,
                              itemBuilder: (context, index) {
                                var current = provider.testimonies[index];
                                return current.buildWidget(context);
                              },
                            ),
                          );
                        },
                      ),
            ),
            if (isLoading) loadingBar(),
          ],
        ),

        // bouton flottant
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed:
                  () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CreateTestimony(),
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 3,
              child: cusFaIcon(FontAwesomeIcons.feather, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
