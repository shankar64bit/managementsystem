import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionEditPage extends StatefulWidget {
  final String questionBankId;
  final String questionId;
  final String questionText;
  final String questionType;
  final String questionDifficulty;
  final String questionSubject;

  QuestionEditPage({
    required this.questionBankId,
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.questionDifficulty,
    required this.questionSubject,
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

  @override
  void initState() {
    super.initState();
    _questionText = widget.questionText;
    _selectedType = widget.questionType;
    _selectedDifficulty = widget.questionDifficulty;
    _selectedSubject = widget.questionSubject;
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
          child: Column(
            children: [
              TextFormField(
                initialValue: _questionText,
                decoration: InputDecoration(labelText: 'Question Text'),
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
                decoration: InputDecoration(labelText: 'Type'),
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
                decoration: InputDecoration(labelText: 'Difficulty'),
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Update the question in Firestore
                    FirebaseFirestore.instance
                        .collection('questionBanks')
                        .doc(widget.questionBankId)
                        .collection('questions')
                        .doc(widget.questionId)
                        .update({
                      'title': _questionText, // Updated field
                      'type': _selectedType,
                      'difficulty': _selectedDifficulty,
                      'subject': _selectedSubject,
                      'questionBank': widget
                          .questionBankId, // Assuming this is the reference to the bank
                      'createdAt': Timestamp.now(), // Update timestamp
                    }).then((_) {
                      Navigator.pop(context);
                    }).catchError((error) {
                      // Handle any errors here
                      print("Failed to update question: $error");
                    });
                  }
                },
                child: Text('Update Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
