import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  String id;
  String name;
  String email;
  Map<String, StudentAssessment> assessments;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.assessments,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      assessments: (data['assessments'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              StudentAssessment.fromMap(value),
            ),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'assessments':
          assessments.map((key, value) => MapEntry(key, value.toMap())),
    };
  }
}

class StudentAssessment {
  Map<String, dynamic> answers;
  int progress;
  Timestamp? savedAt;
  Timestamp? submittedAt;
  String status;

  StudentAssessment({
    required this.answers,
    required this.progress,
    this.savedAt,
    this.submittedAt,
    this.status = 'in progress',
  });

  factory StudentAssessment.fromMap(Map<String, dynamic> data) {
    return StudentAssessment(
      answers: data['answers'] ?? {},
      progress: data['progress'] ?? 0,
      savedAt: data['savedAt'],
      submittedAt: data['submittedAt'],
      status: data['status'] ?? 'in progress',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'answers': answers,
      'progress': progress,
      'savedAt': savedAt,
      'submittedAt': submittedAt,
      'status': status,
    };
  }
}
