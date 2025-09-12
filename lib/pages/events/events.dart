import 'package:aesd/components/fields.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AllEvents extends StatefulWidget {
  const AllEvents({super.key});

  @override
  State<AllEvents> createState() => _AllEventsState();
}

class _AllEventsState extends State<AllEvents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomFormTextField(
                    prefix: const Icon(Icons.search),
                    label: "Recherche",
                    suffix: PopupMenuButton(
                        icon: const FaIcon(FontAwesomeIcons.sort,
                            color: Colors.grey, size: 20),
                        itemBuilder: (context) {
                          return const [
                            PopupMenuItem(
                                value: "date", child: Text("Trier par date")),
                            PopupMenuItem(
                                value: "title", child: Text("Trier par titre")),
                          ];
                        })),

                // liste des articles
                SizedBox(
                  height: MediaQuery.of(context).size.height * .75,
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                          10,
                          (index) => customEventBox(context,
                              title: "Titre de l'article", date: "12-12-2000")),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Widget customEventBox(
    BuildContext context, {
    required String title,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(
              image: AssetImage("assets/event.jpg"), fit: BoxFit.cover)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.green.withOpacity(.7),
                  Colors.green.withOpacity(.3),
                ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              date,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: Colors.white60),
            )
          ],
        ),
      ),
    );
  }
}
