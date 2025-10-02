import 'dart:io';

import 'package:aesd/models/day_program.dart';
import 'package:aesd/models/program.dart';
import 'package:aesd/requests/program_request.dart';
import 'package:flutter/material.dart';

class ProgramProvider extends ChangeNotifier {
  final _handler = ProgramRequest();
  final List<DayProgramModel> _dayPrograms = [];
  DayProgramModel? _selectedDayProgram;
  ProgramModel? _selectedProgram;

  List<DayProgramModel> get dayPrograms => _dayPrograms;
  ProgramModel? get selectedProgram => _selectedProgram;
  DayProgramModel? get selectedDayProgram => _selectedDayProgram;

  Future getChurchPrograms(int churchId) async {
    final programsByDayMap = {};
    final response = await _handler.getAll(churchId);
    for (var progJson in response.data['programmes']) {
      final program = ProgramModel.fromJson(progJson);
      final day = program.day;

      // Si le jour n'existe pas encore dans la map, l'initialiser
      if (!programsByDayMap.containsKey(day)) {
        programsByDayMap[day] = [];
      }
      programsByDayMap[day].add(program);
    }

    programsByDayMap.forEach((day, programsList) {
      dayPrograms.add(DayProgramModel(day: day, program: programsList));
    });

    if (response.statusCode) {
      return true;
    } else {
      throw HttpException("Impossible de récupérer les programmes");
    }
  }

  Future getDayPrograms(int churchId, String day) async {
    final response = await _handler.getAll(churchId);
  }

  Future getProgram(int programId) async {
    final response = await _handler.getOne(programId);
    if (response.statusCode) {
      _selectedProgram = ProgramModel.fromJson(response.data);
    }
  }
}