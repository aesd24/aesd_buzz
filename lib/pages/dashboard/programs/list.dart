import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/models/day_program.dart';
import 'package:aesd/pages/dashboard/programs/create.dart';
import 'package:aesd/provider/program.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ProgramListPage extends StatefulWidget {
  const ProgramListPage({super.key});

  @override
  State<ProgramListPage> createState() => _ProgramListPageState();
}

class _ProgramListPageState extends State<ProgramListPage> {
  int? churchId;
  bool _isLoading = false;
  final List<DayProgramModel> _programs = [];

  Future init(int churchId) async {
    try {
      setState(() => _isLoading = true);
      await Provider.of<ProgramProvider>(
        context,
        listen: false,
      ).getChurchPrograms(churchId);
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      churchId = Get.arguments["churchId"];
      if (churchId != null) init(churchId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: FaIcon(FontAwesomeIcons.xmark, size: 20),
        ),
        centerTitle: true,
        title: Text("Programme", style: TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child:
            _programs.isEmpty
                ? Center(
                  child: notFoundTile(
                    text: "Aucun programme à afficher pour le moment.",
                  ),
                )
                : ListView.builder(
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'heroBtn',
        backgroundColor: notifire.getMainColor,
        onPressed:
            () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => CreateProgramForm(churchId: churchId!),
            ),
        shape: CircleBorder(),
        child: cusFaIcon(FontAwesomeIcons.circlePlus, color: Colors.white),
      ),
    );
  }
}
