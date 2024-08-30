class Question {
  String id;
  String text;
  String type;
  String difficulty;
  String subject;
  List<String>? options;
  String? feedback;
  String? media; // For images, videos, etc.

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.difficulty,
    required this.subject,
    this.options,
    this.feedback,
    this.media,
  });

  factory Question.fromMap(Map<String, dynamic> data) {
    return Question(
      id: data['id'] ?? '',
      text: data['text'] ?? '',
      type: data['type'] ?? '',
      difficulty: data['difficulty'] ?? '',
      subject: data['subject'] ?? '',
      options: (data['options'] as List<dynamic>?)?.cast<String>(),
      feedback: data['feedback'],
      media: data['media'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'type': type,
      'difficulty': difficulty,
      'subject': subject,
      'options': options,
      'feedback': feedback,
      'media': media,
    };
  }
}
