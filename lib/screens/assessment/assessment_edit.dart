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
  final TextEditingController _instructionController = TextEditingController();

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

    // Fetching fields from Firestore
    _titleController.text = assessment['title'];
    _typeController.text = assessment['type'];
    _questionBankController.text = assessment['questionBank'] ?? '';

    // Handle questions as a list
    if (assessment['questions'] is List) {
      _questionsController.text = (assessment['questions'] as List).join(', ');
    } else {
      _questionsController.text = assessment['questions'] ?? '';
    }

    _timeLimitController.text = assessment['timeLimit']?.toString() ?? '';
    _maxAttemptsController.text = assessment['maxAttempts']?.toString() ?? '';
    _feedbackController.text = assessment['feedback'] ?? '';
    _instructionController.text = assessment['instructions'] ?? '';
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
          ? _questionsController.text.split(',').map((q) => q.trim()).toList()
          : null,
      'timeLimit': int.tryParse(_timeLimitController.text) ?? 0,
      'maxAttempts': int.tryParse(_maxAttemptsController.text) ?? 0,
      'feedback':
          _feedbackController.text.isNotEmpty ? _feedbackController.text : null,
      'instructions': _instructionController.text.isNotEmpty
          ? _instructionController.text
          : null,
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
              decoration:
                  InputDecoration(labelText: 'Questions (comma-separated)'),
            ),
            TextField(
              controller: _timeLimitController,
              decoration: InputDecoration(labelText: 'Time Limit (minutes)'),
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
            TextField(
              controller: _instructionController,
              decoration: InputDecoration(labelText: 'Instructions'),
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
