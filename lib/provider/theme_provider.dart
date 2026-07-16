import 'package:flutter/material.dart';
import 'package:quiz_app_2/utils/shared_pref_service/shared_pref.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDark = false;

  Future<void> loadTheme() async {
    isDark = await SharedPref.getTheme();
    notifyListeners();
  }

  //button toggle korar jonno

  Future<void> toggleTheme(bool val) async {
    isDark = val;
    await SharedPref.saveTheme(val);
    notifyListeners();
  }
}
