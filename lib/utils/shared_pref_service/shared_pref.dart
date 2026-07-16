import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

//save data (theme)
class SharedPref {
  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dthema", isDark);
  }

  //get data (theme)
  static Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("dthema") ?? false;
  }

  //save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
  }

  //get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  //save role

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  //get role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  //clear auth ata
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user_role");
  }

  //quiz kotobar
  //static const String _totalQuizKey = "total_quizzes_taken";
//when i am locally saving in my phone.
// static Future<void> saveTotalQuizzesTaken(int value) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setInt(_totalQuizKey, value);
// }

// static Future<int> getTotalQuizzesTaken() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getInt(_totalQuizKey) ?? 0;
// }

//now i am gonna integrate firebase.
//save total quizzes taken
static Future<void> saveTotalQuizzesTaken(int value) async {
  final prefs = await SharedPreferences.getInstance();

  final uid = FirebaseAuth.instance.currentUser!.uid;

  await prefs.setInt("total_quizzes_taken_$uid", value);
}

//get total quizzes taken

static Future<int> getTotalQuizzesTaken() async {
  final prefs = await SharedPreferences.getInstance();

  final uid = FirebaseAuth.instance.currentUser!.uid;

  return prefs.getInt("total_quizzes_taken_$uid") ?? 0;
}


}
