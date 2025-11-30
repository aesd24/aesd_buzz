import 'dart:io';

import 'package:aesd/models/day_program.dart';
import 'package:aesd/models/program.dart';
import 'package:aesd/requests/program_request.dart';
import 'package:dio/dio.dart';
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
    dayPrograms.clear();
    final response = await _handler.getAll(churchId);
    if (response.statusCode == 200) {
      final map = response.data['data']['programmes'] as Map<String, dynamic>;
      map.forEach((key, value) {
        dayPrograms.add(
          DayProgramModel(
            day: key,
            program:
                (value as List).map((e) => ProgramModel.fromJson(e)).toList(),
          ),
        );
      });
      return true;
    } else {
      throw HttpException("Impossible de récupérer les programmes");
    }
  }

  Future getProgram(int programId) async {
    final response = await _handler.getOne(programId);
    if (response.statusCode) {
      _selectedProgram = ProgramModel.fromJson(response.data);
    }
  }

  Future createProgram(Map<String, dynamic> data) async {
    if (data['file'] != null) {
      data['file'] = await MultipartFile.fromFile(data['file'].path);
    }
    final formData = FormData.fromMap(data);
    final response = await _handler.create(formData);
    print(response.statusCode);
    if (response.statusCode == 201) {
      return true;
    } else {
      throw HttpException("Impossible de créer le programme");
    }
  }

  Future deleteAnyProgram(int programId) async {
    final response = await _handler.deleteAny(programId);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw HttpException("Impossible de supprimer le programme");
    }
  }

  Future deleteProgramsOfDay({
    required String day,
    required int churchId,
  }) async {
    final response = await _handler.deleteAllOfDay(day, churchId: churchId);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw HttpException("Impossible de supprimer les programmes");
    }
  }
}
