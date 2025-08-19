import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/drawer.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/pages/social/forum/list.dart';
import 'package:aesd/pages/social/social.dart';
import 'package:aesd/provider/auth.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _pageIndex = 0;
  void setPageIndex(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppMenuDrawer(),
      appBar: AppBar(
        toolbarHeight: 70,
        leading: Consumer<Auth>(
          builder: (context, provider, child) {
            final user = provider.user!;
            return Padding(
              padding: const EdgeInsets.only(left: 10),
              child: GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
                child: CircleAvatar(
                  backgroundImage:
                      user.photo != null
                          ? FastCachedImageProvider(user.photo!)
                          : null,
                  backgroundColor: Colors.grey.shade300,
                  child:
                      user.photo == null
                          ? SvgPicture.asset(
                            "assets/illustrations/user-avatar.svg",
                          )
                          : null,
                ),
              ),
            );
          },
        ),
        title: Image.asset(
          'assets/icons/launcher_icon.png',
          height: 40,
          width: 40,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child:
            [
              SocialPage(),
              ForumMain(),
              Placeholder(),
              Placeholder(),
            ][_pageIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (index) => setPageIndex(index),
        unselectedItemColor: notifire.getMainText.withAlpha(180),
        selectedItemColor: notifire.getMainText,
        items: [
          BottomNavigationBarItem(
            icon: cusFaIcon(FontAwesomeIcons.house),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: cusFaIcon(FontAwesomeIcons.usersLine),
            label: "Forum",
          ),
          BottomNavigationBarItem(
            icon: cusFaIcon(FontAwesomeIcons.solidCircleQuestion),
            label: "Quiz",
          ),
          BottomNavigationBarItem(
            icon: cusFaIcon(FontAwesomeIcons.peopleArrows),
            label: "Témoignage",
          ),
        ],
      ),
    );
  }
}
