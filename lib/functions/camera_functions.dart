import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'file_functions.dart';

FutureOr<File?> pickImage({bool camera = true}) async {
  /*
  Permet de récupérer une image via la caméra ou la galérie
    * camera : bool -> indique la source vers laquelle sélectionner l'image
    (si 'true' alors image prise avec la caméra)
  */
  try{
    XFile? capture = await ImagePicker().pickImage(source: camera ? ImageSource.camera : ImageSource.gallery);
    if (capture != null){
      final verif = await verifyVideoSize(File(capture.path));
      if (!verif.isGood) {
        throw Exception("La vidéo est trop lourde : ${verif.length}Mo");
      }
      return File(capture.path);
    }
  } catch (e) {
    e.printError();
  }
  return null;
}

Future<File?> pickVideo({bool camera = false}) async {
  try{
    XFile? capture = await ImagePicker().pickVideo(source: camera ? ImageSource.camera : ImageSource.gallery);
    if (capture != null){
      final verif = await verifyVideoSize(File(capture.path));
      if (!verif.isGood) {
        throw Exception("La vidéo est trop lourde : ${verif.length}Mo");
      }
      return File(capture.path);
    }
  } catch (e) {
    e.printError();
  }
}