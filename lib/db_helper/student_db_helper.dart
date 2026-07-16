import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/studentmodel.dart';

class StudentDbHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collectionStudents = 'students';

  static Future<void> addNewStudents(StudentModel studentModel) {
    return _db
        .collection(_collectionStudents)
        .doc(studentModel.uid)
        .set(studentModel.toMap());
  }

  // Get current student
  static Future<StudentModel?> getStudentByUid(String uid) async {
    final snapshot = await _db.collection(_collectionStudents).doc(uid).get();

    if (!snapshot.exists) return null;

    return StudentModel.fromMap(snapshot.data()!);
  }

  // Leaderboard
  static Future<List<StudentModel>> getTopStudents() async {
    final snapshot = await _db
        .collection(_collectionStudents)
        .orderBy('score', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => StudentModel.fromMap(doc.data()))
        .toList();
  }


  //update score
  static Future<void> updateStudentScore({
  required String uid,
  required int score,
}) async {
  await _db.collection(_collectionStudents).doc(uid).update({
    'score': FieldValue.increment(score),
    'quizTaken': FieldValue.increment(1),
  });
}

  
}
