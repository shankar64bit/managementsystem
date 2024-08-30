import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../questionBank/question_bank.dart';
import '../questionBank/question_creation_page.dart'; // Import your QuestionCreationPage

class AssessmentCreationPage extends StatefulWidget {
  @override
  _AssessmentCreationPageState createState() => _AssessmentCreationPageState();
}

class _AssessmentCreationPageState extends State<AssessmentCreationPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _type = 'Quiz';
  String _questionBank = 'Select a question bank';
  List<Map<String, dynamic>> _questions = [];
  final TextEditingController _questionController = TextEditingController();
  int _timeLimit = 0;
  int _maxAttempts = 0;
  String _feedback = '';
  String _instructions = '';

  void _addQuestion() {
    if (_questionController.text.isNotEmpty) {
      setState(() {
        _questions.add({
          'id': 'custom_${_questions.length}', // Custom question identifier
          'text': _questionController.text,
          'type': 'Short Answer', // Default type, can be modified
          'correctAnswer': '',
          'feedback': '',
        });
        _questionController.clear();
      });
    }
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _saveAssessment() {
    if (_formKey.currentState!.validate()) {
      String newDocId =
          FirebaseFirestore.instance.collection('assessments').doc().id;

      FirebaseFirestore.instance.collection('assessments').doc(newDocId).set({
        'id': newDocId,
        'title': _title,
        'type': _type,
        'questionBankId':
            _questionBank != 'Select a question bank' ? _questionBank : null,
        'questions': _questions, // Custom questions added manually
        'timeLimit': _timeLimit,
        'maxAttempts': _maxAttempts,
        'feedbackType':
            'Immediate', // Example: "Immediate" or "After Completion"
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'instructions': _instructions,
        'hasTimer': _timeLimit > 0,
      }).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        // Handle the error properly in your UI
        print('Error saving assessment: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save assessment. Please try again.'),
        ));
      });
    }
  }

  void _selectQuestionFromBank() async {
    if (_questionBank != 'Select a question bank') {
      final questionsSnapshot = await FirebaseFirestore.instance
          .collection('questionBanks')
          .doc(_questionBank)
          .collection('questions')
          .get();

      final questionsFromBank =
          questionsSnapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        _questions.addAll(questionsFromBank.cast<Map<String, dynamic>>());
      });
    }
  }

  void _manageQuestionBank() {
    if (_questionBank != 'Select a question bank') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionBankPage(questionBankId: _questionBank),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a question bank first!'),
      ));
    }
  }

  void _createNewQuestion() {
    if (_questionBank != 'Select a question bank') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              QuestionCreationPage(questionBankId: _questionBank),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a question bank first!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Assessment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Assessment Title'),
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Time Limit (minutes)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _timeLimit = int.tryParse(value) ?? 0;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Maximum Attempts'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _maxAttempts = int.tryParse(value) ?? 0;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Feedback'),
                onChanged: (value) {
                  setState(() {
                    _feedback = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Instructions'),
                onChanged: (value) {
                  setState(() {
                    _instructions = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: ['Quiz', 'Assignment', 'Survey']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Assessment Type'),
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _questionBank,
                      items: [
                        'Select a question bank',
                        'Question Bank 1', // These should be dynamic or real IDs from Firestore
                        'Question Bank 2'
                      ]
                          .map((bank) => DropdownMenuItem(
                                value: bank,
                                child: Text(bank),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _questionBank = value!;
                          _selectQuestionFromBank(); // Auto-add questions from selected bank
                        });
                      },
                      decoration: InputDecoration(labelText: 'Question Bank'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: _manageQuestionBank,
                    tooltip: 'Manage Question Bank',
                  ),
                ],
              ),
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'Enter a question',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addQuestion,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title:
                          Text(_questions[index]['text'] ?? 'No Question Text'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeQuestion(index),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAssessment,
                child: Text('Save Assessment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
