import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/models/church_model.dart';
import 'package:aesd/models/day_program.dart';
import 'package:aesd/pages/program/create.dart';
import 'package:aesd/provider/program.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ProgramListPage extends StatefulWidget {
  const ProgramListPage({super.key, required this.church});

  final ChurchModel church;

  @override
  State<ProgramListPage> createState() => _ProgramListPageState();
}

class _ProgramListPageState extends State<ProgramListPage> {
  bool _isLoading = false;
  final List<DayProgramModel> _programs = [];

  Future init() async {
    try {
      setState(() => _isLoading = true);
      await Provider.of<ProgramProvider>(
        context,
        listen: false,
      ).getChurchPrograms(widget.church.id);
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur est survenue");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: FaIcon(FontAwesomeIcons.xmark, size: 20),
        ),
        centerTitle: true,
        title: Text("Programme", style: TextStyle(fontSize: 20)),
      ),
      body:
          _isLoading
              ? ListShimmerPlaceholder()
              : Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    CustomElevatedButton(
                      text: "Ajouter un programme",
                      icon: FaIcon(
                        FontAwesomeIcons.plus,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Get.to(CreateProgramForm()),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: _programs.length,
                        itemBuilder: (context, index) {
                          final current = _programs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: current.getWidget(context),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
