

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_2/models/cqmodel.dart';

import '../db_helper/quiz_db_helper.dart';

import '../provider/quiz_provider.dart';
import '../models/firebase_category_model.dart';

class AddQuizScreenA extends StatefulWidget {
  const AddQuizScreenA({super.key});

  @override
  State<AddQuizScreenA> createState() => _AddQuizScreenStateA();
}

class _AddQuizScreenStateA extends State<AddQuizScreenA> {
  final questionController = TextEditingController();
  final option1Controller = TextEditingController();
  final option2Controller = TextEditingController();
  final option3Controller = TextEditingController();
  final option4Controller = TextEditingController();

  FirebaseCategoryModel? selectedCategory;
  int correctAnswer = 0;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
context.read<QuizProvider>().fetchCategories();

  }

  void saveQuestion() async {

    log("============ Save questions");

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category first!')),
      );
      return;
    }

    if (questionController.text.isEmpty ||
        option1Controller.text.isEmpty ||
        option2Controller.text.isEmpty ||
        option3Controller.text.isEmpty ||
        option4Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields!')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final question = QuestionModel(
        whatQ: questionController.text,
        options: [
          option1Controller.text,
          option2Controller.text,
          option3Controller.text,
          option4Controller.text,
        ],
        answer: correctAnswer,
      );

      await QuizDbHelper.saveQuestion(selectedCategory!.id, question);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving quiz: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Add Quiz',
          
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [

              Consumer<QuizProvider>(
                builder: (context, quizProvider, child) {
                  if (quizProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (quizProvider.errorMesg != null && quizProvider.firebaseCategories.isEmpty) {
                    return Text('Error loading categories: ${quizProvider.errorMesg}');
                  }
                  final categories = quizProvider.firebaseCategories;
                  if (categories.isEmpty) {
                    return const Text('No categories found in Firebase.');
                  }

                  // Ensure selected category is valid
                  if (selectedCategory != null && !categories.any((c) => c.id == selectedCategory!.id)) {
                    selectedCategory = null;
                  }

                  return DropdownButtonFormField<FirebaseCategoryModel>(
                    decoration: const InputDecoration(
                      labelText: "Select Category",
                      border: OutlineInputBorder(),
                    ),
                    initialValue: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  );
                },
              ),



              const SizedBox(height: 25),

              // Questions
              CustomTextformFiled(
                questionController: questionController,
                labelText: 'Question',
              ),
              const SizedBox(height: 10),

              // options - 01
              CustomTextformFiled(
                questionController: option1Controller,
                labelText: "Option 1",
              ),
              const SizedBox(height: 10),

              //Option - 02
              CustomTextformFiled(
                questionController: option2Controller,
                labelText: 'Options 2',
              ),
              const SizedBox(height: 10),

              // options - 03
              CustomTextformFiled(
                questionController: option3Controller,
                labelText: "Option 3",
              ),
              const SizedBox(height: 10),

              // options - 4
              CustomTextformFiled(
                questionController: option4Controller,
                labelText: "Option 4",
              ),
              const SizedBox(height: 20),

              // correct ans
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Correct Answer",
                  border: OutlineInputBorder(),
                ),
                initialValue: correctAnswer,
                items: const [
                  DropdownMenuItem(value: 0, child: Text("Option 1")),
                  DropdownMenuItem(value: 1, child: Text("Option 2")),
                  DropdownMenuItem(value: 2, child: Text("Option 3")),
                  DropdownMenuItem(value: 3, child: Text("Option 4")),
                ],
                onChanged: (value) {
                  setState(() {
                    correctAnswer = value!;
                  });
                },
              ),
              const SizedBox(height: 30),

              // Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isSaving ? null : saveQuestion,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Quiz", style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextformFiled extends StatelessWidget {
  final TextEditingController questionController;
  final String labelText;

  const CustomTextformFiled({
    super.key,
    required this.questionController,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: questionController,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}