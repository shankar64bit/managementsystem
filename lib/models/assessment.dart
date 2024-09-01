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
  int? popularity;
  double? completionRate; // Changed to double for more accuracy

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
    this.popularity,
    this.completionRate,
  });

  // Factory constructor to create an Assessment object from a map
  factory Assessment.fromMap(Map<String, dynamic> map) {
    return Assessment(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      questionBank: map['questionBank'],
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      timeLimit: map['timeLimit'] ?? 0,
      maxAttempts: map['maxAttempts'] ?? 0,
      feedback: map['feedback'] ?? '',
      instructions: map['instructions'] ?? '',
      hasTimer: map['hasTimer'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'],
      popularity: map['popularity'] ?? 0, // Default to 0 if null
      completionRate: (map['completionRate'] as num?)?.toDouble() ??
          0.0, // Default to 0.0 if null
    );
  }

  // Factory constructor to create an Assessment object directly from a Firestore document
  factory Assessment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Assessment(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      questionBank: data['questionBank'],
      questions: (data['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      timeLimit: data['timeLimit'] ?? 0,
      maxAttempts: data['maxAttempts'] ?? 0,
      feedback: data['feedback'] ?? '',
      instructions: data['instructions'] ?? '',
      hasTimer: data['hasTimer'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
      popularity: data['popularity'] ?? 0,
      completionRate: (data['completionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Converts the Assessment object to a Map for saving to Firestore
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
      'popularity': popularity,
      'completionRate': completionRate,
    };
  }
}
