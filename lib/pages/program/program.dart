import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/divider.dart';
import 'package:aesd/pages/program/create.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ChurchProgram extends StatefulWidget {
  const ChurchProgram({super.key, required this.churchId});

  final int churchId;

  @override
  State<ChurchProgram> createState() => _ChurchProgramState();
}

class _ChurchProgramState extends State<ChurchProgram> {
  final List<Map<String, dynamic>> _programs = List.generate(5, (index) {
    return {
      'day': "Jour $index",
      'program': List.generate(3, (index) {
        return {
          'title': "Programme $index",
          'time': "${index + 10}h00 - ${index + 11}h00",
          'place': "Lien $index",
        };
      }),
    };
  });

  late List<Widget>? _programBoxes;
  int activeProgram = 0;
  final _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _programBoxes = List.generate(_programs.length, (index) {
      var current = _programs[index];
      return CustomProgramBox(
        day: current['day'],
        programs: current['program'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              textDivider("Programme hebdomadaire"),
              CustomTextButton(
                label: "Ajouter",
                onPressed: () => Get.to(CreateProgramForm()),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_programs.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.bounceIn,
                      );
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 1),
                      color: activeProgram == index ? Colors.green : null,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                );
              }),
            ),
          ),
          _programBoxes != null
              ? SizedBox(
                height: 350,
                child: PageView.builder(
                  itemCount: _programs.length,
                  controller: _pageController,
                  onPageChanged: (value) {
                    setState(() {
                      activeProgram = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _programBoxes![index];
                  },
                ),
              )
              : Text(
                "Aucun programme disponible",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Colors.grey.shade300,
                ),
              ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              textDivider("Evenements"),
              CustomTextButton(label: "Ajouter"),
            ],
          ),
          const SizedBox(height: 10),
          /*SizedBox(
            height: 500,
            width: double.infinity,
            child: SingleChildScrollView(
                child: Column(
                    children: List.generate(10, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: customEventBox(context,
                    title: "Evenement ${index + 1}",
                    date: "${index + 1}/${index + 1}/2024",
                    height: 160),
              );
            }))),
          )*/
        ],
      ),
    );
  }

  TextButton trailButton({
    required String text,
    required Widget icon,
    required void Function() onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon,
      iconAlignment: IconAlignment.end,
      label: Text(text),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(Colors.green),
      ),
    );
  }
}

class CustomProgramBox extends StatelessWidget {
  const CustomProgramBox({
    super.key,
    required this.day,
    required this.programs,
  });

  final String day;
  final List programs;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(right: 10),
      width: size.width - 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 1.5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              day,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 260,
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(programs.length, (index) {
                  var current = programs[index];
                  return Column(
                    children: [
                      programTile(
                        context,
                        title: "Programme ${current['title']}",
                        time: current['time'],
                        place: current['place'],
                      ),
                      if (index != 2) const Divider(),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget programTile(
    BuildContext context, {
    required String title,
    required String time,
    required String place,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(title, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.locationPin,
                size: 15,
                color: Colors.grey,
              ),
              const SizedBox(width: 7),
              Text(place),
            ],
          ),
        ],
      ),
    );
  }
}
