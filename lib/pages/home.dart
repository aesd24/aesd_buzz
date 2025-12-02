import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/certification_banner.dart';
import 'package:aesd/components/drawer.dart';
import 'package:aesd/pages/forum/list.dart';
import 'package:aesd/pages/quiz/home.dart';
import 'package:aesd/pages/social/social.dart';
import 'package:aesd/pages/testimony/list.dart';
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

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _pageIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void setPageIndex(int index) {
    if (_pageIndex != index) {
      _animationController.forward().then((_) {
        setState(() {
          _pageIndex = index;
        });
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppMenuDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildModernAppBar(context),
            getCertificationBanner(context) ?? const SizedBox.shrink(),
            Expanded(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(_pageIndex),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: [
                        SocialPage(),
                        ForumMain(),
                        QuizHome(),
                        TestimoniesList(),
                      ][_pageIndex],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildModernBottomNav(context),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Consumer<Auth>(
              builder: (context, provider, child) {
                final user = provider.user!;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _scaffoldKey.currentState!.openDrawer();
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: user.photo != null
                            ? FastCachedImageProvider(user.photo!)
                            : null,
                        backgroundColor: Colors.grey.shade200,
                        child: user.photo == null
                            ? SvgPicture.asset(
                                "assets/illustrations/user-avatar.svg",
                                width: 28,
                                height: 28,
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/launcher_icon.png',
                height: 32,
                width: 32,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: FontAwesomeIcons.house,
                label: "Home",
                index: 0,
              ),
              _buildNavItem(
                context,
                icon: FontAwesomeIcons.usersLine,
                label: "Forum",
                index: 1,
              ),
              _buildNavItem(
                context,
                icon: FontAwesomeIcons.solidCircleQuestion,
                label: "Quiz",
                index: 2,
              ),
              _buildNavItem(
                context,
                icon: FontAwesomeIcons.peopleArrows,
                label: "Témoignage",
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _pageIndex == index;
    final theme = Theme.of(context);
    final selectedColor = theme.primaryColor;
    final unselectedColor = notifire.getMainText.withAlpha(180);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setPageIndex(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? selectedColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isSelected ? 8 : 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FaIcon(
                    icon,
                    size: isSelected ? 22 : 20,
                    color: isSelected ? selectedColor : unselectedColor,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 12 : 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? selectedColor : unselectedColor,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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