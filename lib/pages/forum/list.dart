import 'dart:io';
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
    return isLoading ? Scaffold(
      body: ListShimmerPlaceholder(),
    ) : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: CustomFormTextField(
            label: "Recherche",
            prefix: cusIcon(Icons.search)
          )
        ),
        Expanded(
          child: Consumer<Forum>(
            builder: (context, forum, child) {
              if (forum.subjects.isNotEmpty) {
                return RefreshIndicator(
                  strokeWidth: 1.5,
                  onRefresh: () async {
                    await loadSubjects();
                  },
                  child: ListView.builder(
                    itemCount: forum.subjects.length,
                    itemBuilder: (context, index) {
                      var element = forum.subjects[index];
                      return element.toTile(context);
                    },
                  ),
                );
              } else {
                return notFoundTile(
                  text: "Aucun sujet de discution disponible",
                );
              }
            },
          ),
        ),
        if (isLoading) loadingBar(),
      ],
    );
  }

  Widget forumDiscutionBox(
    BuildContext context, {
    required String title,
    required int responseNumber,
    required void Function()? onClick,
  }) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: (size.width * .5) - 20,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  responseNumber.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 3),
                const FaIcon(FontAwesomeIcons.message, size: 17),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
