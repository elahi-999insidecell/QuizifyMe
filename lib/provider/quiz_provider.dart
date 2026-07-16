import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiz_app_2/db_helper/quiz_db_helper.dart';
import 'package:quiz_app_2/models/cqmodel.dart';
import 'package:quiz_app_2/models/firebase_category_model.dart';
import 'package:quiz_app_2/utils/shared_pref_service/shared_pref.dart';

class QuizProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMesg;
  int totalQuizzesTaken = 0;

  Map<int, int> selectedOptions = {};

  List<FirebaseCategoryModel> firebaseCategories = [];
  StreamSubscription? _categoriesSubscription;

  QuizProvider() {
    loadTotalQuizzesTaken();
  }

  // ===========================
  // Quiz Answer
  // ===========================

  void selectedOpt(int questionIndex, int optionIndex) {
    selectedOptions[questionIndex] = optionIndex;
    notifyListeners();
  }

  int calculateScore(CategoryModel category) {
    int score = 0;

    for (int i = 0; i < category.questions.length; i++) {
      if (selectedOptions[i] == category.questions[i].answer) {
        score++;
      }
    }

    return score;
  }

  void resetQuiz() {
    selectedOptions.clear();
    notifyListeners();
  }

  // ===========================
  // Categories
  // ===========================

  void fetchCategories() {
    isLoading = true;
    errorMesg = null;
    notifyListeners();

    _categoriesSubscription?.cancel();

    _categoriesSubscription =
        QuizDbHelper.getAllCategories().listen((snapshot) async {
      List<FirebaseCategoryModel> temp = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final count = await QuizDbHelper.getQuestionCount(doc.id);

        temp.add(
          FirebaseCategoryModel(
            id: doc.id,
            name: data['name'] ?? '',
            questioncount: count,
          ),
        );
      }

      firebaseCategories = temp;
      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      errorMesg = e.toString();
      isLoading = false;
      notifyListeners();
    });
  }

  // ===========================
  // Shared Preferences
  // ===========================

  Future<void> loadTotalQuizzesTaken() async {
    totalQuizzesTaken = await SharedPref.getTotalQuizzesTaken();
    notifyListeners();
  }

  Future<void> incrementTotalQuizzesTaken() async {
    totalQuizzesTaken++;

    await SharedPref.saveTotalQuizzesTaken(totalQuizzesTaken);

    notifyListeners();
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    super.dispose();
  }
}