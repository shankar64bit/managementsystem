// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'question.dart';

// class QuestionBank {
//   String id;
//   String name;
//   List<Question> questions;
//   Timestamp createdAt;

//   QuestionBank({
//     required this.id,
//     required this.name,
//     required this.questions,
//     required this.createdAt,
//   });

//   factory QuestionBank.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data() as Map<String, dynamic>;
//     return QuestionBank(
//       id: doc.id,
//       name: data['name'] ?? '',
//       questions: (data['questions'] as List<dynamic>?)
//               ?.map((q) => Question.fromMap(q))
//               .toList() ??
//           [],
//       createdAt: data['createdAt'],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'questions': questions.map((q) => q.toMap()).toList(),
//       'createdAt': createdAt,
//     };
//   }
// }
