import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionEditPage extends StatefulWidget {
  final String questionBankId;
  final String questionId;
  final String questionText;
  final String questionType;
  final String questionDifficulty;
  final String questionSubject;
  final String correctAnswer;

  QuestionEditPage({
    required this.questionBankId,
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.questionDifficulty,
    required this.questionSubject,
    required this.correctAnswer,
  });

  @override
  _QuestionEditPageState createState() => _QuestionEditPageState();
}

class _QuestionEditPageState extends State<QuestionEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _questionText;
  late String _selectedType;
  late String _selectedDifficulty;
  late String _selectedSubject;
  late String _selectedcorrectAnswer;

  @override
  void initState() {
    super.initState();
    _questionText = widget.questionText;
    _selectedType = widget.questionType;
    _selectedDifficulty = widget.questionDifficulty;
    _selectedSubject = widget.questionSubject;
    _selectedcorrectAnswer = widget.correctAnswer;
  }

  void _updateQuestion() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance
          .collection('questionBanks')
          .doc(widget.questionBankId)
          .collection('questions')
          .doc(widget.questionId)
          .update({
        'text': _questionText,
        'type': _selectedType,
        'difficulty': _selectedDifficulty,
        'subject': _selectedSubject,
        '_correctAnswer': _selectedcorrectAnswer,
        'updatedAt': Timestamp.now(),
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question updated successfully')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update question: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _questionText,
                decoration: InputDecoration(
                  labelText: 'Question Text',
                  hintText: 'Enter the question text here',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
                onChanged: (value) {
                  _questionText = value;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items:
                    ['Multiple-choice', 'Short answer', 'Essay', 'True/False']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                items: ['Easy', 'Medium', 'Hard']
                    .map((difficulty) => DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Difficulty',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                items: ['Math', 'Science', 'History']
                    .map((subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _updateQuestion,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Update Question',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
