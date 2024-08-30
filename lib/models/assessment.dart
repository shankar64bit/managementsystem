import 'package:cloud_firestore/cloud_firestore.dart';

import 'question.dart';

class Assessment {
  String id;
  String title;
  String type;
  String? questionBank;
  List<Question> questions;
  int timeLimit;
  int maxAttempts;
  String feedback;
  String instructions;
  bool hasTimer;
  Timestamp createdAt;
  Timestamp? updatedAt;

  Assessment({
    required this.id,
    required this.title,
    required this.type,
    this.questionBank,
    required this.questions,
    required this.timeLimit,
    required this.maxAttempts,
    required this.feedback,
    required this.instructions,
    required this.hasTimer,
    required this.createdAt,
    this.updatedAt,
  });

  factory Assessment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Assessment(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      questionBank: data['questionBank'],
      questions: (data['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromMap(q))
              .toList() ??
          [],
      timeLimit: data['timeLimit'] ?? 0,
      maxAttempts: data['maxAttempts'] ?? 0,
      feedback: data['feedback'] ?? '',
      instructions: data['instructions'] ?? '',
      hasTimer: data['hasTimer'] ?? false,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'questionBank': questionBank,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeLimit': timeLimit,
      'maxAttempts': maxAttempts,
      'feedback': feedback,
      'instructions': instructions,
      'hasTimer': hasTimer,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
