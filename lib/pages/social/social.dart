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

  /// Notifier pour demander la navigation vers un onglet précis.
  /// Appelé depuis l'extérieur (ex: church_banner) même si SocialPage est déjà construite.
  static final ValueNotifier<int?> navigateToTab = ValueNotifier(null);

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage>
    with SingleTickerProviderStateMixin {
  String ElementsDisplayed = "post";
  final List _elements = [
    //"Evenements",
    "Actualités",
    "Posts",
    "Eglises",
    "Serviteurs",
    "Chantres"
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _elements.length,
      vsync: this,
    );
    // Écouter les demandes de navigation externes
    SocialPage.navigateToTab.addListener(_onNavigateToTab);
  }

  void _onNavigateToTab() {
    final requestedIndex = SocialPage.navigateToTab.value;
    if (requestedIndex != null && mounted) {
      _tabController.animateTo(requestedIndex);
      SocialPage.navigateToTab.value = null; // Réinitialiser
    }
  }

  @override
  void dispose() {
    SocialPage.navigateToTab.removeListener(_onNavigateToTab);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // tabBar pour choisir les éléments à afficher
        TabBar(
          controller: _tabController,
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
            controller: _tabController,
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
    );
  }
}
