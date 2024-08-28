import 'package:cloud_firestore/cloud_firestore.dart';

class Assessment {
  final String id;
  final String title;
  final String type;
  final String questionBank;
  final List<String> questions;
  final int timeLimit;
  final int maxAttempts;
  final String feedback;
  final Timestamp createdAt;
  final String instructions;

  Assessment({
    required this.id,
    required this.title,
    required this.type,
    required this.questionBank,
    required this.questions,
    required this.timeLimit,
    required this.maxAttempts,
    required this.feedback,
    required this.createdAt,
    required this.instructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'questionBank': questionBank,
      'questions': questions,
      'timeLimit': timeLimit,
      'maxAttempts': maxAttempts,
      'feedback': feedback,
      'createdAt': createdAt,
      'instructions': instructions,
    };
  }

  factory Assessment.fromMap(Map<String, dynamic> map) {
    return Assessment(
      id: map['id'],
      title: map['title'],
      type: map['type'],
      questionBank: map['questionBank'],
      questions: List<String>.from(map['questions']),
      timeLimit: map['timeLimit'],
      maxAttempts: map['maxAttempts'],
      feedback: map['feedback'],
      createdAt: map['createdAt'],
      instructions: map['instructions'],
    );
  }
}
