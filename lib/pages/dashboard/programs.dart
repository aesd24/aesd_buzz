import 'package:aesd/components/buttons.dart';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/models/day_program.dart';
import 'package:aesd/pages/program/create.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ProgramListPage extends StatefulWidget {
  const ProgramListPage({super.key, this.church});

  final ChurchModel? church;

  @override
  State<ProgramListPage> createState() => _ProgramListPageState();
}

class _ProgramListPageState extends State<ProgramListPage> {

  final List<DayProgramModel> _programs = List.generate(7, (index){
    return DayProgramModel.fromJson({
      'day': "Jour",
      'program': List.generate(3, (index) {
        return {
          'title': "Programme $index",
          'startTime': "${index + 10}:00:00",
          'endTime': "${index + 11}:00:00",
          'place': "Lien $index"
        };
      })
    });
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: FaIcon(FontAwesomeIcons.xmark, size: 20)
        ),
        centerTitle: true,
        title: Text("Programme", style: TextStyle(fontSize: 20))
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomElevatedButton(
                text: "Ajouter un programme",
                icon: FaIcon(
                  FontAwesomeIcons.plus,
                  color: Colors.white,
                  size: 20
                ),
                onPressed: () => Get.to(CreateProgramForm()
                )
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: List.generate(7, (index){
                    var current = _programs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: current.getWidget(context)
                    );
                  }),
                ),
              )
            ]
          ),
        ),
      ),
    );
  }
}