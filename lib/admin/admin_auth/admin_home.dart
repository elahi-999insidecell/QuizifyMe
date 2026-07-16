// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_2/provider/auth_provider.dart';
import 'package:quiz_app_2/provider/quiz_provider.dart';
import 'package:quiz_app_2/widgets/categorycard.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().fetchCategories();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin DashBoard"),
        centerTitle: true,

        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await context.read<AuthProvider>().logOUTAdmin();
              if (context.mounted) {
                context.go('/role-selection');
              }
            },
          ),
        ],
      ),

      //quiz adding
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push("/add-quiz-admin").then((_) {
            // Refresh categories on return just in case
            if (mounted) {
              context.read<QuizProvider>().fetchCategories();
            }
          });
        },
        label: const Text('Add Quiz'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: Consumer<QuizProvider>(
        builder: (context, quizprovider, child) {
          if (quizprovider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          final categories = quizprovider.firebaseCategories;
          return ListView.builder(
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(
                title: category.name,
                subtitle: "${category.questioncount} Questions",
                icon: Icons.book,
                click: () {
                  context.push("/admin-quiz-list", extra: category);
                },
              );
            },
            itemCount: categories.length,
          );
        },
      ),
    );
  }
}
