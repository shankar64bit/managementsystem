import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentEditPage extends StatefulWidget {
  final String assessmentId;

  AssessmentEditPage({required this.assessmentId});

  @override
  _AssessmentEditPageState createState() => _AssessmentEditPageState();
}

class _AssessmentEditPageState extends State<AssessmentEditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _questionBankController = TextEditingController();
  final TextEditingController _questionsController = TextEditingController();
  final TextEditingController _timeLimitController = TextEditingController();
  final TextEditingController _maxAttemptsController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAssessment();
  }

  void _fetchAssessment() async {
    DocumentSnapshot assessment = await FirebaseFirestore.instance
        .collection('assessments')
        .doc(widget.assessmentId)
        .get();
    _titleController.text = assessment['title'];
    _typeController.text = assessment['type'];
    _questionBankController.text = assessment['questionBank'] ?? '';
    _questionsController.text = assessment['questions'] ?? '';
    _timeLimitController.text = assessment['timeLimit']?.toString() ?? '';
    _maxAttemptsController.text = assessment['maxAttempts']?.toString() ?? '';
    _feedbackController.text = assessment['feedback'] ?? '';
  }

  void _updateAssessment() {
    FirebaseFirestore.instance
        .collection('assessments')
        .doc(widget.assessmentId)
        .update({
      'title': _titleController.text,
      'type': _typeController.text,
      'questionBank': _questionBankController.text.isNotEmpty
          ? _questionBankController.text
          : null,
      'questions': _questionsController.text.isNotEmpty
          ? _questionsController.text
          : null,
      'timeLimit': int.tryParse(_timeLimitController.text) ?? 0,
      'maxAttempts': int.tryParse(_maxAttemptsController.text) ?? 0,
      'feedback':
          _feedbackController.text.isNotEmpty ? _feedbackController.text : null,
    }).then((_) {
      Navigator.pop(context); // Go back to the detail page
    }).catchError((error) {
      // Handle any errors here
      print("Failed to update assessment: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Assessment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: _questionBankController,
              decoration: InputDecoration(labelText: 'Question Bank'),
            ),
            TextField(
              controller: _questionsController,
              decoration: InputDecoration(labelText: 'Questions'),
            ),
            TextField(
              controller: _timeLimitController,
              decoration: InputDecoration(labelText: 'Time Limit (in seconds)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _maxAttemptsController,
              decoration: InputDecoration(labelText: 'Max Attempts'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(labelText: 'Feedback'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateAssessment,
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
