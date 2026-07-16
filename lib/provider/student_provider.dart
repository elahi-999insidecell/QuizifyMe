// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../db_helper/student_db_helper.dart';
import '../models/studentmodel.dart';
import '../utils/shared_pref_service/shared_pref.dart';

class StudentSignUpProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;
  List<StudentModel> _topStudents = [];
StudentModel? _currentStudent;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  
List<StudentModel> get topStudents => _topStudents;
StudentModel? get currentStudent => _currentStudent;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUpStudent(StudentModel student) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: student.email,
        password: student.password,
      );

      if (credential.user != null) {
        student.uid = credential.user!.uid;
        await StudentDbHelper.addNewStudents(student);
        
        // Save the uid as token and set role
        await SharedPref.saveToken(credential.user!.uid);
        await SharedPref.saveRole('student');
        
        _setLoading(false);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? "Sign up failed";
    } catch (e) {
      _errorMessage = "An unexpected error occurred.";
    }

    _setLoading(false);
    return false;
  }

  Future<bool> loginStudent(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      
      if (userCredential.user != null) {
        // Save the uid as token and set role
        await SharedPref.saveToken(userCredential.user!.uid);
        await SharedPref.saveRole('student');
        await fetchCurrentUser();
        _setLoading(false);
        return true;
      }

    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? "Authentication failed";
    } catch (e) {
      _errorMessage = "An unexpected error occurred.";
    }

    _setLoading(false);
    return false;
  }


  //curent stu
  Future<void> fetchCurrentUser() async {
  _setLoading(true);
  _errorMessage = null;

  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      _currentStudent = await StudentDbHelper.getStudentByUid(uid);
    }
  } catch (e) {
    _errorMessage = "Failed to load current student: $e";
  }

  _setLoading(false);
}

//fetch topper
Future<void> fetchTopStudents() async {
  _setLoading(true);
  _errorMessage = null;

  try {
    _topStudents = await StudentDbHelper.getTopStudents();
  } catch (e) {
    _errorMessage = "Failed to load leaderboard: $e";
  }

  _setLoading(false);
}

//logout
Future<void> logout() async {
  await _auth.signOut();

  await SharedPref.clearAuthData();

  _currentStudent = null;
  _topStudents.clear();

  notifyListeners();
}


//subscription
Future<void> updateSubscriptionStatus(
  bool isSubscribed,
  String subscriptionStatus,
  String? msisdn,
) async {
  if (_currentStudent == null) return;

  _currentStudent!.isSubscribed = isSubscribed;
  _currentStudent!.subscriptionStatus = subscriptionStatus;

  if (msisdn != null && msisdn.isNotEmpty) {
    _currentStudent!.msisdn = msisdn;
  }

  await StudentDbHelper.addNewStudents(_currentStudent!);

  notifyListeners();
}
}