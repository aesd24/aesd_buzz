import 'package:aesd/components/fields.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/components/structure.dart';
import 'package:aesd/provider/news.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsList extends StatefulWidget {
  const NewsList({super.key});

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: CustomFormTextField(
                label: "Recherche",
                prefix: cusIcon(Icons.search),
              ),
            ),
            Expanded(
              child: isLoading ? ListShimmerPlaceholder() : Consumer<News>(
                builder: (context, provider, child) {
                  if (provider.news.isEmpty) {
                    return notFoundTile(text: "Aucun évènement trouvé");
                  }
                  return RefreshIndicator(
                    onRefresh: () async {}, //=> await loadEvents(),
                    child: ListView.builder(
                      itemCount: provider.news.length,
                      itemBuilder: (context, index) {
                        var current = provider.news[index];
                        return current.getWidget(context);
                      },
                    ),
                  );
                },
              ),
            ),
            if (isLoading) loadingBar(),
          ],
        ),
      ],
    );
  }
}
