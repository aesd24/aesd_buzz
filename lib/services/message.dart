import 'package:flutter/material.dart';

class MessageService {
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static GlobalKey<ScaffoldMessengerState> getScaffoldMessengerKey() => scaffoldMessengerKey;

  static void _showSnackBar(
      String message,
      IconData icon,
      Color bgColor,
      Color fgColor,
    ) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: fgColor, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                overflow: TextOverflow.clip,
                style: TextStyle(color: fgColor),
              ),
            ),
          ],
        ),
        elevation: 2,
        duration: const Duration(seconds: 3),
        backgroundColor: bgColor,
      )
    );
  }

  static void showSuccessMessage(String message) {
    _showSnackBar(message, Icons.check_circle, Colors.green, Colors.white);
  }

  static void showErrorMessage(String message) {
    _showSnackBar(message, Icons.error, Colors.red, Colors.white);
  }

  static void showWarningMessage(String message) {
    _showSnackBar(message, Icons.warning, Colors.orange, Colors.white);
  }

  static void showInfoMessage(String message) {
    _showSnackBar(message, Icons.info, Colors.blue, Colors.white);
  }
}