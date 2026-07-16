// ignore_for_file: prefer_is_empty

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_2/provider/student_provider.dart';
import 'package:quiz_app_2/widgets/leaderboard_card.dart';
import 'package:quiz_app_2/widgets/top_rank_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentSignUpProvider>().fetchTopStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentSignUpProvider>();
    final students = provider.topStudents;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Leaderboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff00796B),
              Color(0xff26A69A),
              Color(0xffE0F2F1),
            ],
          ),
        ),
        child: SafeArea(
          child: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : students.isEmpty
                  ? const Center(
                      child: Text(
                        "No participants yet.",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [

                            const SizedBox(height: 8),

                            const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.amber,
                              size: 70,
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Top Quiz Champions",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Compete, Learn & Climb the Rankings",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 30),

                            if (students.length >= 1)
                              TopRankCard(
                                student: students[0],
                                rank: 1,
                              ),

                            const SizedBox(height: 16),

                            if (students.length >= 2)
                              TopRankCard(
                                student: students[1],
                                rank: 2,
                              ),

                            const SizedBox(height: 16),

                            if (students.length >= 3)
                              TopRankCard(
                                student: students[2],
                                rank: 3,
                              ),

                            const SizedBox(height: 30),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Other Rankings",
                                style: TextStyle(
                                  color: Colors.teal.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: students.length > 3
                                  ? students.length - 3
                                  : 0,
                              itemBuilder: (context, index) {
                                final student = students[index + 3];

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 14),
                                  child: LeaderboardCard(
                                    student: student,
                                    rank: index + 4,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}