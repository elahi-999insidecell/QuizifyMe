//category model
import 'package:flutter/material.dart';

class CategoryModel {
  final String categoryName;
  IconData iconData;
  final List<QuestionModel> questions;

  CategoryModel({
    required this.categoryName,
    required this.iconData,
    required this.questions,
  });
}

//question model

class QuestionModel {
  final String whatQ;
  final List<String> options;
  final int answer;

  QuestionModel({
    required this.whatQ,
    required this.options,
    required this.answer,
  });
}





