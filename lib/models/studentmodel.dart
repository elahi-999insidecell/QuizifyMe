class StudentModel {
  String name;
  String email;
  String password;
  String phoneNumber;
  String msisdn;
  String uid;
  int score;
  int quizTaken;
  bool isSubscribed;
  String subscriptionStatus;

  StudentModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.uid,
    this.msisdn = '',
    this.score = 0,
    this.quizTaken = 0,
    this.isSubscribed = false,
    this.subscriptionStatus = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'msisdn': msisdn,
      'score': score,
      'quizTaken': quizTaken,
      'isSubscribed': isSubscribed,
      'subscriptionStatus': subscriptionStatus,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      msisdn: map['msisdn'] ?? '',
      score: (map['score'] != null)
          ? (map['score'] is num ? (map['score'] as num).toInt() : int.tryParse(map['score'].toString()) ?? 0)
          : 0,
      quizTaken: (map['quizTaken'] != null)
          ? (map['quizTaken'] is num ? (map['quizTaken'] as num).toInt() : int.tryParse(map['quizTaken'].toString()) ?? 0)
          : 0,
      isSubscribed: map['isSubscribed'] ?? false,
      subscriptionStatus: map['subscriptionStatus'] ?? '',
    );
  }
}