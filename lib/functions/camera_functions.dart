import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

FutureOr<File?> pickImage({bool camera = true}) async {
  /*
  Permet de récupérer une image via la caméra ou la galérie
    * camera : bool -> indique la source vers laquelle sélectionner l'image
    (si 'true' alors image prise avec la caméra)
  */
  try{
    XFile? capture = await ImagePicker().pickImage(source: camera ? ImageSource.camera : ImageSource.gallery);
    if (capture != null){
      return File(capture.path);
    }
  } catch (e) {
    e.printError();
  }
  return null;
}

FutureOr<File?> pickVideo({bool camera = false}) async {
  /*
  Permet de récupérer une vidéo via la caméra ou la galérie

    * camera : bool -> indique la source vers laquelle sélectionner la vidéo
    (si 'true' alors la vidéo est prise avec la caméra)
  */
  try{
    XFile? capture = await ImagePicker().pickVideo(source: camera ? ImageSource.camera : ImageSource.gallery);
    if (capture != null){
      return File(capture.path);
    }
  } catch (e) {
    e.printError();
  }
  return null;
}