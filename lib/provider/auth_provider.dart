import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:quiz_app_2/db_helper/auth_db_helper.dart';
import 'package:quiz_app_2/utils/shared_pref_service/shared_pref.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isloading = false;
  String? _errMesg;

  bool get isloading => _isloading;
  String? get errorMesg => _errMesg;

  void _setLoading(bool val) {
    _isloading = val;
    notifyListeners();
  }

  Future<bool> logINAdmin(String email, String password) async {
    _setLoading(true);
    _errMesg = null;

    try {
      final userCredentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredentials.user != null) {
        final isAdmin = await AuthDbHelper.checkAdmin(email);
        if (isAdmin) {
          await SharedPref.saveToken(userCredentials.user!.uid);
          await SharedPref.saveRole('admin');

          _setLoading(false);
        }
        return true;
      } else {
        await _auth.signOut();
        _errMesg = "You are not an admin";
        _setLoading(false);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _errMesg = e.message;
      _setLoading(false);
      return false;
    } catch (error) {
      _errMesg = error.toString();
    }

    _isloading = false;
    notifyListeners();
    return false;
  }

  Future<void> logOUTAdmin() async {
    await SharedPref.clearAuthData();
    await _auth.signOut();
  }
}
