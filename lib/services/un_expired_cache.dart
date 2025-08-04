import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UnExpiredCache {
  Future<dynamic> get({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(key).toString());
  }

  Future<void> put({required String key, value}) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
