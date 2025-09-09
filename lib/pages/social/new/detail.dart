import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/image_viewer.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/functions/formatteurs.dart';
import 'package:aesd/provider/news.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  bool isLoading = true;

  Future loadActuality(int id) async {
    try {
      await Provider.of<News>(context, listen: false).getAny(id);
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } on DioException {
      MessageService.showErrorMessage(
        "Erreur réseau. Vérifiez votre connexion internet",
      );
    } catch (e) {
      MessageService.showErrorMessage("Une erreur inattendu s'est produite.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      int newsId = Get.arguments['newId'] as int;
      await loadActuality(newsId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(strokeWidth: 1.5))
              : Consumer<News>(
                builder: (context, provider, child) {
                  if (provider.selectedNews == null) {
                    return Center(
                      child: notFoundTile(
                        text: "Impossible de récupérer l'actualité",
                        icon: FontAwesomeIcons.newspaper,
                      ),
                    );
                  }
                  final actu = provider.selectedNews!;
                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        leading: customBackButton(color: Colors.white),
                        expandedHeight: MediaQuery.of(context).size.height * .5,
                        pinned: true,
                        automaticallyImplyLeading: false,
                        flexibleSpace: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  actu.imageUrl != null
                                      ? FastCachedImageProvider(actu.imageUrl!)
                                      : AssetImage("assets/news.jpeg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withAlpha(170),
                                  Colors.black.withAlpha(20),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child:
                                actu.imageUrl != null
                                    ? Align(
                                      alignment: Alignment.bottomRight,
                                      child: TextButton.icon(
                                        onPressed:
                                            () => Get.to(
                                              ImageViewer(
                                                imageUrl: actu.imageUrl!,
                                              ),
                                            ),
                                        label: Text("Voir l'image"),
                                        icon: cusFaIcon(
                                          FontAwesomeIcons.eye,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                        iconAlignment: IconAlignment.end,
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                notifire.getbgcolor.withAlpha(
                                                  70,
                                                ),
                                              ),
                                          foregroundColor:
                                              WidgetStatePropertyAll(
                                                notifire.getbgcolor,
                                              ),
                                          overlayColor: WidgetStatePropertyAll(
                                            notifire.getbgcolor.withAlpha(70),
                                          ),
                                        ),
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    cusFaIcon(
                                      FontAwesomeIcons.calendar,
                                      size: 16,
                                    ),
                                    SizedBox(width: 15),
                                    Text(
                                      formatDate(actu.date),
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),

                              // titre de l'actualité
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  actu.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium!.copyWith(
                                    color: notifire.getMainText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // contenu de l'actualité
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                child: Text(
                                  actu.content,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }
}
