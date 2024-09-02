import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionCreationPage extends StatefulWidget {
  final String questionBankId;

  QuestionCreationPage({required this.questionBankId});

  @override
  _QuestionCreationPageState createState() => _QuestionCreationPageState();
}

class _QuestionCreationPageState extends State<QuestionCreationPage> {
  final _formKey = GlobalKey<FormState>();
  String _questionText = '';
  String _selectedType = 'Multiple-choice';
  String _selectedDifficulty = 'Easy'; // Added difficulty field
  String _selectedSubject = 'Math'; // Added subject field
  String _correctAnswer = '';
  List<String> _options = [];
  final TextEditingController _optionController = TextEditingController();

  void _addOption() {
    if (_optionController.text.isNotEmpty) {
      setState(() {
        _options.add(_optionController.text);
        _optionController.clear();
      });
    }
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> questionData = {
        'text': _questionText,
        'type': _selectedType,
        'difficulty': _selectedDifficulty, // Added difficulty field
        'subject': _selectedSubject, // Added subject field
        'correctAnswer': _correctAnswer,
        'options': _selectedType == 'Multiple-choice' ? _options : [],
        'createdAt': Timestamp.now(),
      };

      FirebaseFirestore.instance
          .collection('questionBanks')
          .doc(widget.questionBankId)
          .collection('questions')
          .add(questionData)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question saved successfully')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save question: $error')),
        );
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
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Question Text',
                  hintText: 'Enter the question text here',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) {
                  setState(() {
                    _questionText = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the question text';
                  }
                  return null;
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
                    if (_selectedType != 'Multiple-choice') {
                      _options.clear();
                    }
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Question Type',
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
                  labelText: 'Question Difficulty',
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
              SizedBox(height: 20),
              if (_selectedType == 'Multiple-choice') ...[
                TextFormField(
                  controller: _optionController,
                  decoration: InputDecoration(
                    labelText: 'Option',
                    hintText: 'Enter an option',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addOption,
                  child: Text('Add Option'),
                ),
                SizedBox(height: 20),
                Column(
                  children: List.generate(
                    _options.length,
                    (index) => ListTile(
                      title: Text(_options[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () => _removeOption(index),
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Correct Answer',
                  hintText: 'Enter the correct answer here',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _correctAnswer = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the correct answer';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveQuestion,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Save Question',
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
