// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';
import 'package:quiz_app_2/models/cqmodel.dart';
import 'package:quiz_app_2/widgets/customtextformfield.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  //controllers
  final questionController = TextEditingController();
  final option1Controller = TextEditingController();
  final option2Controller = TextEditingController();
  final option3Controller = TextEditingController();
  final option4Controller = TextEditingController();
  

  
  final List<QuestionModel> questions = [];
  String selectedCategory = "Science";
  int? answer;

  //function to save quiz
  // void saveQuestion() {
  //   for (var i in categories) {
  //     if (i.categoryName == selectedCategory) {
  //       i.questions.add(
  //         QuestionModel(
  //           whatQ: questionController.text,
  //           options: [
  //             option1Controller.text,
  //             option2Controller.text,
  //             option3Controller.text,
  //             option4Controller.text,
  //           ],
  //           answer: answer! , // blank answers wont be accepted because of the dropdown button, it will always have a value
  //         ),
  //       );
  //       break;
  //     }
  //   }
  //   Navigator.pop(context);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Quiz"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // DropdownButtonFormField(
               
              //   initialValue: selectedCategory,
              //   items: categories.map((category) {
              //     return DropdownMenuItem(
              //       value: category.categoryName,
              //       child: Text(category.categoryName),
              //     );
              //   }).toList(),
        
              //   onChanged: (value) {
              //     setState(() {
              //       selectedCategory = value!;
              //     });
              //   },
        
              //   decoration: InputDecoration(
              //     labelText: "Select Category",
              //     labelStyle: TextStyle(color: Colors.teal),
        
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8),
              //       borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
              //     ),
        
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8),
              //       borderSide: const BorderSide(color: Colors.teal, width: 2),
              //     ),
              //   ),
              // ),
        
              SizedBox(height: 20),
        
              //question
              customTextFormfield(
                questionController: questionController,
                labelText: "Question",
              ),
              SizedBox(height: 10),
              
              
              //option1
              customTextFormfield(
                questionController: option1Controller,
                labelText: "Option 1",
              ),
              SizedBox(height: 10),
              //option2
              customTextFormfield(
                questionController: option2Controller,
                labelText: "Option 2",
              ),
              SizedBox(height: 10),
              //option3
              customTextFormfield(
                questionController: option3Controller,
                labelText: "Option 3",
              ),
              SizedBox(height: 10),
              //option4
              customTextFormfield(
                questionController: option4Controller,
                labelText: "Option 4",
              ),
              SizedBox(height: 20),
              
        
              //correct ans
              DropdownButtonFormField ( 
                
                initialValue: answer,
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text("Option 1"),),
                    DropdownMenuItem(
                    value: 1,
                    child: Text("Option 2"),),
                    DropdownMenuItem(
                    value: 2,
                    child: Text("Option 3"),),
                    DropdownMenuItem(
                    value: 3,
                    child: Text("Option 4"),)
                ], 
                onChanged: (value) { 
                  setState ((){
                    answer = value!;
                  });
                 },
        
        
                //decoration
                decoration: InputDecoration(
                  labelText: "Correct Answer",
                  labelStyle: TextStyle(color: Colors.teal),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
        
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                ),
              ),
              
        
              
          SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(onPressed: () {
                  //saveQuestion();
                  },
                  //button ta cute korlam
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,),
                  //button text 
                 child: Text("Save Quiz", style: TextStyle(fontSize: 18, color: Colors.white),), 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

