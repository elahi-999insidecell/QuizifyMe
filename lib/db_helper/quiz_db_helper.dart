import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app_2/models/cqmodel.dart';

class QuizDbHelper {
  static const String _collectionCategory = "Categories";
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCategories() =>
      _db.collection(_collectionCategory).snapshots();


 static Future<void> saveQuestion(String categoryId, QuestionModel question) async {
     await _db.collection(_collectionCategory)
         .doc(categoryId)
         .collection('Questions')
         .add({
       'question': question.whatQ,
       'options': question.options,
       'correctAnswer': question.answer,
     });
   }

   //get question
    static Future<List<QuestionModel>> getQuestions(String categoryId) async {
     final snapshot = await _db.collection(_collectionCategory)
         .doc(categoryId)
         .collection('Questions')
         .get();

     return snapshot.docs.map((doc) {
       final data = doc.data();
       return QuestionModel(
         whatQ: data['question'] ?? '',
         options: List<String>.from(data['options'] ?? []),
         answer: data['correctAnswer'] ?? 0,
       );
     }).toList();
   }


   //question count
    static Future<int> getQuestionCount(String categoryId) async {
     final snapshot = await _db.collection(_collectionCategory)
         .doc(categoryId)
         .collection('Questions')
         .count()
         .get();
     return snapshot.count ?? 0;
   }




}
