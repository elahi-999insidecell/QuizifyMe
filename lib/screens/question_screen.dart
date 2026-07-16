// ignore_for_file: use_build_context_synchronously, unused_element, unused_field

import 'dart:async';
import 'package:quiz_app_2/db_helper/quiz_db_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_2/db_helper/student_db_helper.dart';
import 'package:quiz_app_2/models/cqmodel.dart';
import 'package:quiz_app_2/models/firebase_category_model.dart';
import 'package:quiz_app_2/provider/quiz_provider.dart';

class QuestionScreen extends StatefulWidget {
  
  final FirebaseCategoryModel category;
  const QuestionScreen({super.key, required this.category});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late Future<List<QuestionModel>> _questionFuture;
  //timer
  Timer? _timer;
  int _timeLeft = 60;
  bool _timerStarted = false;
  List<QuestionModel> _questions = [];
 @override
void initState() {
  super.initState();
 context.read<QuizProvider>().resetQuiz();
  _questionFuture = QuizDbHelper.getQuestions(widget.category.id);
}

  //timer starting function
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();

       

        final currentCategory = CategoryModel(
  categoryName: widget.category.name,
  iconData: Icons.book,
  questions: _questions,
);

final quizProvider = context.read<QuizProvider>();

final score = quizProvider.calculateScore(currentCategory);

await StudentDbHelper.updateStudentScore(
  uid: FirebaseAuth.instance.currentUser!.uid,
  score: score,
);

await quizProvider.incrementTotalQuizzesTaken();

context.go(
  "/result",
  extra: currentCategory,
);
      }
    });
  }

  //dispose timer

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  //main app
  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // title: Text(widget.category.categoryName),
          title: Text(widget.category.name),
          foregroundColor: Colors.white,
          backgroundColor: Colors.teal,
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  "${_timeLeft}s",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder<List<QuestionModel>>(
          future: _questionFuture,
          //pore question add hbe
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(color: Colors.red, fontSize: 24),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "Error: No questions available",
                  style: TextStyle(color: Colors.red, fontSize: 24),
                ),
              );
            }

            final que = snapshot.data!;
            _questions = que;

            if (!_timerStarted) {
              _timerStarted = true;
              _startTimer();
            }
            final cuurentCategory = CategoryModel(
              categoryName: widget.category.name,
              iconData: Icons.book,
              questions: que,
            );
            return ListView.builder(
              //etake future builder diye wrap korlam
              itemCount:
                  // widget.category.questions.length + 1, //model theke anbo
                  que.length + 1,
              itemBuilder: (context, questionIndex) {
                //question model theke anbo
                //final ques = category.questions[questionIndex];
                // if (questionIndex == widget.category.questions.length) {
                if (questionIndex == que.length) {
                  return Column(
                    children: [
                      SizedBox(height: 20),
                      SizedBox(
  height: 58,
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () async {
      _timer?.cancel();

      final quizProvider = context.read<QuizProvider>();

      final score = quizProvider.calculateScore(cuurentCategory);

      await StudentDbHelper.updateStudentScore(
        uid: FirebaseAuth.instance.currentUser!.uid,
        score: score,
      );

      await quizProvider.incrementTotalQuizzesTaken();

      if (!mounted) return;

      context.go(
        "/result",
        extra: cuurentCategory,
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      elevation: 10,
      shadowColor: Colors.teal.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.emoji_events_rounded,
          color: Colors.amber,
          size: 28,
        ),
        SizedBox(width: 12),
        Text(
          "Submit Quiz",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(width: 12),
        Icon(
          Icons.arrow_forward_rounded,
          size: 24,
        ),
      ],
    ),
  ),
),
                      SizedBox(height: 20),
                    ],
                  );
                }

                //final ques = widget.category.questions[questionIndex];
                final ques = que[questionIndex];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  elevation: 5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),),
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Question ${questionIndex + 1}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          ques.whatQ,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        SizedBox(height: 8),
                        Column(
                          children: List.generate(ques.options.length, (
                            optionIndex,
                          ) {
                            final isSelected =
                                quizProvider.selectedOptions[questionIndex] ==
                                optionIndex;
                    
                            return InkWell(
  borderRadius: BorderRadius.circular(14),
  onTap: () {
    context.read<QuizProvider>().selectedOpt(
      questionIndex,
      optionIndex,
    );
  },
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: isSelected
          ? Colors.teal
          : Colors.teal.shade50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isSelected
            ? Colors.teal
            : Colors.teal.shade200,
        width: 2,
      ),
    ),
    child: Row(
      children: [
        Icon(
          isSelected
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: isSelected
              ? Colors.white
              : Colors.teal,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            ques.options[optionIndex],
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ),
      ],
    ),
  ),
);
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
