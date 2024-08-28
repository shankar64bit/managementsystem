import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionCreationPage extends StatefulWidget {
  final String questionBankId; // Accept questionBankId as a parameter

  QuestionCreationPage({required this.questionBankId});

  @override
  _QuestionCreationPageState createState() => _QuestionCreationPageState();
}

class _QuestionCreationPageState extends State<QuestionCreationPage> {
  final _formKey = GlobalKey<FormState>();
  String _questionText = '';
  String _selectedType = 'Multiple Choice';
  String _selectedDifficulty = 'Easy';
  String _selectedSubject = 'Math';

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance
          .collection('questionBanks')
          .doc(widget.questionBankId)
          .collection('questions')
          .add({
        'text': _questionText,
        'type': _selectedType,
        'difficulty': _selectedDifficulty,
        'subject': _selectedSubject,
        'createdAt': Timestamp.now(),
      }).then((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Question Text'),
                onChanged: (value) {
                  setState(() {
                    _questionText = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the question text';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: ['Multiple Choice', 'True/False', 'Essay']
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
                decoration: InputDecoration(labelText: 'Question Type'),
              ),
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
                decoration: InputDecoration(labelText: 'Question Difficulty'),
              ),
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
                decoration: InputDecoration(labelText: 'Subject'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveQuestion,
                child: Text('Save Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
