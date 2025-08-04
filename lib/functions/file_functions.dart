import 'dart:io';

// Mégaoctets
const int maxImageSize = 20;
const int maxVideoSize = 300;
const int divider = 1048576;

Future<Map<String, dynamic>> verifyImageSize(File file) async {
  int length = await file.length();
  bool result = true;

  // si la taille du fichier est supérieur à maxImageSize
  if ((length / divider) > maxImageSize) {
    result = false;
  }
  return {'result': result, 'length': (length / divider).toStringAsFixed(2)};
}

Future<VerificationResult> verifyVideoSize(File file) async {
  int length = await file.length();
  bool result = true;

  // si la taille de la vidéo est supérieur à maxVideoSize
  if (length / divider > maxVideoSize) {
    result = false;
  }
  return VerificationResult(
    isGood: result,
    length: (length / divider).toStringAsFixed(2)
  );
}

class VerificationResult {
  bool isGood;
  String length;

  VerificationResult({required this.isGood, required this.length});
}
