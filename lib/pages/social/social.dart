import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/pages/social/church/list.dart';
import 'package:aesd/pages/social/event/list.dart';
import 'package:aesd/pages/social/new/list.dart';
import 'package:aesd/pages/social/servants_list.dart';
import 'package:aesd/pages/social/singers_list.dart';
import 'package:flutter/material.dart';
import 'package:aesd/pages/social/posts/list.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  String ElementsDisplayed = "post";
  final List _elements = [
    //"Evenements",
    "Actualités",
    "Posts",
    "Eglises",
    "Serviteurs",
    "Chantres"
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _elements.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // tabBar pour choisir les éléments à afficher
          TabBar(
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            isScrollable: true,
            labelColor: notifire.getMainColor,
            indicatorColor: notifire.getMainColor,
            tabs: List.generate(_elements.length, (index) {
              return Tab(
                child: Text(_elements[index]),
              );
            })
          ),

          SizedBox(height: 20),

          // Contenu de la page en fonction du choix effectué
          Expanded(
            child: TabBarView(
              children: [
                //EventsList(),
                NewsList(),
                PostList(),
                ChurchList(),
                ServantsList(),
                SingersList(),
              ]
            ),
          )
        ],
      ),
    );
  }
}
