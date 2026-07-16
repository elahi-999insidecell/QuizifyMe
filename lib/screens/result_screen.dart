import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_2/models/cqmodel.dart';
import 'package:quiz_app_2/provider/quiz_provider.dart';

class ResultScreen extends StatelessWidget {
  final CategoryModel category;

  const ResultScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final score = quizProvider.calculateScore(category);

    final double percentage = score / category.questions.length;

    String resultTitle;
    String resultMessage;
    IconData resultIcon;
    Color resultColor;

    if (percentage == 1.0) {
      resultTitle = "Perfect Score!";
      resultMessage = "Outstanding! You're a true Quiz Champion!";
      resultIcon = Icons.workspace_premium_rounded;
      resultColor = const Color.fromARGB(255, 224, 170, 7);
    } else if (percentage >= 0.8) {
      resultTitle = "Excellent!";
      resultMessage = "Amazing performance! Keep it up!";
      resultIcon = Icons.emoji_events_rounded;
      resultColor = const Color.fromARGB(255, 224, 170, 7);
    } else if (percentage >= 0.6) {
      resultTitle = "Great Job!";
      resultMessage = "You're doing really well!";
      resultIcon = Icons.stars_rounded;
      resultColor =  const Color.fromARGB(255, 224, 170, 7);
    } else if (percentage >= 0.4) {
      resultTitle = "Good Try!";
      resultMessage = "Practice a little more and you'll improve!";
      resultIcon = Icons.thumb_up_alt_rounded;
      resultColor = const Color.fromARGB(255, 224, 170, 7);
    } else {
      resultTitle = "Keep Practicing!";
      resultMessage = "Every expert was once a beginner. Don't give up!";
      resultIcon = Icons.psychology_alt_rounded;
      resultColor = Colors.teal;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff009688),
                Color(0xff26A69A),
                Color(0xffE8F5E9),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Icon(
                        resultIcon,
                        size: 70,
                        color: resultColor,
                      ),
                    ),
        
                    const SizedBox(height: 20),
        
                    Text(
                      resultTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
        
                    const SizedBox(height: 10),
        
                    Text(
                      resultMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
        
                    const SizedBox(height: 35),
        
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Your Score",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
        
                          const SizedBox(height: 20),
        
                          Container(
                            height: 140,
                            width: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.teal,
                                  Color(0xff26A69A),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "$score/${category.questions.length}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
        
                          const SizedBox(height: 20),
        
                          Text(
                            "${(percentage * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
        
                          const Text(
                            "Accuracy",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
        
                          const SizedBox(height: 25),
        
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.quiz_rounded,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Quiz Taken : ${quizProvider.totalQuizzesTaken}",
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
        
                          const SizedBox(height: 35),
        
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<QuizProvider>().resetQuiz();
                                context.go("/");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                elevation: 10,
                                shadowColor:
                                    Colors.teal.withValues(alpha: 0.45),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.home_rounded),
                                  SizedBox(width: 10),
                                  Text(
                                    "Back to Home",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}