import 'package:cloud_firestore/cloud_firestore.dart';

class AuthDbHelper {
  static const String _collectionAdmin = "Admins";
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<bool> checkAdmin(String email) async {
    final snapshot = await _db
        .collection(_collectionAdmin)
        .where('email', isEqualTo: email)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
