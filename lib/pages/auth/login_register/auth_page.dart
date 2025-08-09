import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/pages/auth/login_register/login.dart';
import 'package:aesd/pages/auth/login_register/register.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoading = false;
  void _reInitPage() {
    _tabController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.bounceIn,
    );
  }

  void _switchLoadingState() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      color: Colors.black45,
      progressIndicator: CircularProgressIndicator(
        strokeWidth: 1.5,
        color: Colors.white,
      ),
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: notifire!.getbgcolor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // custom TabBar
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: appMainColor.withAlpha(50),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: appMainColor,
                        ),
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        tabs: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 30,
                            ),
                            child: cusFaIcon(
                              FontAwesomeIcons.arrowRightToBracket,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 30,
                            ),
                            child: cusFaIcon(FontAwesomeIcons.userPlus),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * .65,
                        minHeight: MediaQuery.of(context).size.height * .5,
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          LoginPage(loadingCallBack: _switchLoadingState),
                          RegisterPage(
                            loadingCallBack: _switchLoadingState,
                            reInitCallBack: _reInitPage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
