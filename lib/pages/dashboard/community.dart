import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../provider/church.dart';

class DashboardCommunityPage extends StatefulWidget {
  const DashboardCommunityPage({super.key, required this.churchId});

  final int churchId;

  @override
  State<DashboardCommunityPage> createState() => _DashboardCommunityPageState();
}

class _DashboardCommunityPageState extends State<DashboardCommunityPage> {
  bool _isLoading = false;
  List<UserModel> members = [];

  final _carouselController = CarouselController(
    initialItem: 1,
  );

  getChurch() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Church>(context, listen: false).fetchChurch(
        widget.churchId
      ).then((value) {
        List<UserModel> tab = [];
        for(var member in value['members']) {
          tab.add(UserModel.fromJson(member));
        }
        setState(() {
          members = tab.where((e) => e.accountType == 'serviteur_de_dieu').toList();
        });
      });
    } catch(e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur inattendue est survenue !");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getChurch();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Get.back(),
              icon: FaIcon(FontAwesomeIcons.xmark, size: 20)
          ),
          title: const Text("Communauté"),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              if (members.isNotEmpty) Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  height: size.height * .25,
                  child: CarouselView(
                    controller: _carouselController,
                    itemExtent: double.infinity,
                    itemSnapping: true,
                    children: List.generate(members.length, (index) {
                      var current = members[index];
                      return Container(
                        color: Colors.grey.withAlpha(70),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey.shade50,
                              backgroundImage: current.photo != null ?
                                NetworkImage(current.photo!) : null,
                            ),
                            SizedBox(height: 20),
                            Text(
                              current.name,
                              style: Theme.of(context).textTheme.labelLarge
                            ),
                            Text(
                              current.email,
                              style: Theme.of(context).textTheme
                                .labelSmall!.copyWith(
                                  color: Colors.black.withAlpha(100)
                                )
                            ),
                            Text(
                              '(+225) ${current.phone}',
                              style: Theme.of(context).textTheme
                                .labelSmall!.copyWith(
                                color: Colors.black.withAlpha(100)
                              )
                            )
                          ],
                        ),
                      );
                    })
                  ),
                ),
              ),
              Card(
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  title: Text('Rechercher un fidèle'),
                  trailing: FaIcon(FontAwesomeIcons.solidUser, size: 20),
                )
              ),
              Card(
                  elevation: 0,
                  color: Colors.white,
                  child: ListTile(
                    title: Text('Créer un groupe de discution'),
                    trailing: FaIcon(FontAwesomeIcons.solidMessage, size: 20),
                  )
              )
            ],
          )
        ),
      ),
    );
  }
}

