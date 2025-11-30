import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/modal.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/pages/dashboard/programs/create.dart';
import 'package:aesd/provider/program.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class ProgramListPage extends StatefulWidget {
  const ProgramListPage({super.key});

  @override
  State<ProgramListPage> createState() => _ProgramListPageState();
}

class _ProgramListPageState extends State<ProgramListPage> {
  int? churchId;
  bool _isLoading = false;
  bool _isProcessing = false;

  Future init(int churchId) async {
    try {
      setState(() => _isLoading = true);
      await Provider.of<ProgramProvider>(
        context,
        listen: false,
      ).getChurchPrograms(churchId);
    }/* catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur est survenue");
    }*/ finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleDayDeletion(String day, int churchId) {
    showModal(
      context: context,
      dialog: CustomAlertDialog(
        title: "Alerte de suppréssion",
        content:
            "Vous allez supprimer tous les programmes du ${day.toUpperCase()}. Confirmer ?",
        actions: [
          CustomTextButton(
            onPressed: () async {
              Get.back();
              await deleteDayPrograms(day, churchId);
            },
            label: "Confirmer",
            type: ButtonType.error.copyWith(
              icon: cusFaIcon(FontAwesomeIcons.trashCan, color: Colors.white),
            ),
          ),
          CustomTextButton(
            onPressed: () => Get.back(),
            label: "Annuler",
            type: ButtonType.info.copyWith(backColor: notifire.getMaingey),
          ),
        ],
      ),
    );
  }

  Future deleteDayPrograms(String day, int churchId) async {
    try {
      setState(() => _isProcessing = true);
      await Provider.of<ProgramProvider>(
        context,
        listen: false,
      ).deleteProgramsOfDay(day: day, churchId: churchId).then((value) async {
        await Provider.of<ProgramProvider>(
          context,
          listen: false,
        ).getChurchPrograms(churchId);
        MessageService.showSuccessMessage("Programmes supprimés avec succès");
      });
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur est survenue");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _handleProgramDeletion(int programId, int churchId) {
    showModal(
      context: context,
      dialog: CustomAlertDialog(
        title: "Alerte de suppréssion",
        content: "Vous allez supprimer ce programme. Continuer ?",
        actions: [
          CustomTextButton(
            onPressed: () async {
              Get.back();
              await deleteProgram(programId, churchId);
            },
            label: "Confirmer",
            type: ButtonType.error.copyWith(
              icon: cusFaIcon(FontAwesomeIcons.trashCan, color: Colors.white),
            ),
          ),
          CustomTextButton(
            onPressed: () => Get.back(),
            label: "Annuler",
            type: ButtonType.info.copyWith(backColor: notifire.getMaingey),
          ),
        ],
      ),
    );
  }

  Future deleteProgram(int programId, int churchId) async {
    try {
      setState(() => _isProcessing = true);
      await Provider.of<ProgramProvider>(
        context,
        listen: false,
      ).deleteAnyProgram(programId).then((value) async {
        await Provider.of<ProgramProvider>(
          context,
          listen: false,
        ).getChurchPrograms(churchId);
        MessageService.showSuccessMessage("Programmes supprimés avec succès");
      });
    } catch (e) {
      e.printError();
      MessageService.showErrorMessage("Une erreur est survenue");
    } finally {
      setState(() => _isProcessing = false);
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

    return LoadingOverlay(
      isLoading: _isProcessing,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: FaIcon(FontAwesomeIcons.xmark, size: 20),
          ),
          centerTitle: true,
          title: Text("Programme", style: TextStyle(fontSize: 20)),
        ),
        body: Consumer<ProgramProvider>(
          builder: (context, provider, child) {
            if (provider.dayPrograms.isEmpty) {
              return Center(
                child: notFoundTile(text: "Aucun programme disponible"),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(15),
              child: ListView.builder(
                itemCount: provider.dayPrograms.length,
                itemBuilder: (context, index) {
                  final current = provider.dayPrograms[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: current.buildWidget(
                      context,
                      reloader: () => setState(() {}),
                      onDeleteDay: (day) => _handleDayDeletion(day, churchId!),
                      onDeleteProgram:
                          (programId) =>
                              _handleProgramDeletion(programId, churchId!),
                    ),
                  );
                },
              ),
            );
          },
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
      ),
    );
  }
}
