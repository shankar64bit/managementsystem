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
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _timeLimitController = TextEditingController();
  final TextEditingController _maxAttemptsController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();

  String? _selectedType; // Use nullable type
  String? _selectedQuestionBank; // Use nullable type
  List<Map<String, dynamic>> _questions = [];
  List<String> _assessmentTypes = [];
  List<String> _questionBanks = [];

  bool _hasTimer = false;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAssessment();
    _loadDropdownData();
  }

  Future<void> _fetchAssessment() async {
    try {
      DocumentSnapshot assessment = await FirebaseFirestore.instance
          .collection('assessments')
          .doc(widget.assessmentId)
          .get();

      if (assessment.exists) {
        Map<String, dynamic> data = assessment.data() as Map<String, dynamic>;
        setState(() {
          _titleController.text = data['title'] ?? '';
          _selectedType = data['type'];
          _selectedQuestionBank = data['questionBank'];
          _questions = (data['questions'] as List<dynamic>?)
                  ?.map((q) => q as Map<String, dynamic>)
                  .toList() ??
              [];
          _timeLimitController.text = data['timeLimit']?.toString() ?? '';
          _maxAttemptsController.text = data['maxAttempts']?.toString() ?? '';
          _feedbackController.text = data['feedback'] ?? '';
          _instructionController.text = data['instructions'] ?? '';
          _hasTimer = data['hasTimer'] ?? false;
        });
      } else {
        setState(() {
          _errorMessage = 'Assessment not found.';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to fetch assessment: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      var typesSnapshot =
          await FirebaseFirestore.instance.collection('assessments').get();
      var banksSnapshot =
          await FirebaseFirestore.instance.collection('questionBanks').get();

      setState(() {
        // Ensure uniqueness using Set
        _assessmentTypes = typesSnapshot.docs
            .map((doc) => doc['type'] as String)
            .toSet()
            .toList();
        _questionBanks = banksSnapshot.docs
            .map((doc) => doc['name'] as String)
            .toSet()
            .toList();
      });
    } catch (e) {
      print('Error loading dropdown data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load dropdown data. Please try again.')),
      );
    }
  }

  void _addQuestion() {
    if (_questionController.text.isNotEmpty) {
      setState(() {
        _questions.add({
          'id': '${_questions.length}_${_questionController.text}',
          'text': _questionController.text,
          'type': _selectedType,
          'correctAnswer': '',
          'feedback': _feedbackController.text,
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

  void _updateAssessment() {
    if (_titleController.text.isEmpty || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and Type are required fields.')),
      );
      return;
    }

    FirebaseFirestore.instance
        .collection('assessments')
        .doc(widget.assessmentId)
        .update({
      'title': _titleController.text,
      'type': _selectedType,
      'questionBank': _selectedQuestionBank,
      'questions': _questions,
      'timeLimit': int.tryParse(_timeLimitController.text) ?? 0,
      'maxAttempts': int.tryParse(_maxAttemptsController.text) ?? 0,
      'feedback': _feedbackController.text,
      'instructions': _instructionController.text,
      'hasTimer': _hasTimer,
      'updatedAt': Timestamp.now(),
    }).then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assessment updated successfully.')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update assessment: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Assessment'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(labelText: 'Title'),
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            items: _assessmentTypes
                                .map((type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value;
                              });
                            },
                            decoration: InputDecoration(labelText: 'Type'),
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedQuestionBank,
                            items: _questionBanks
                                .map((bank) => DropdownMenuItem<String>(
                                      value: bank,
                                      child: Text(bank),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedQuestionBank = value;
                              });
                            },
                            decoration:
                                InputDecoration(labelText: 'Question Bank'),
                          ),
                          TextField(
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
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              itemCount: _questions.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(_questions[index]['text'] ??
                                      'No Question Text'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _removeQuestion(index),
                                  ),
                                );
                              },
                            ),
                          ),
                          TextField(
                            controller: _timeLimitController,
                            decoration: InputDecoration(
                                labelText: 'Time Limit (minutes)'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: _maxAttemptsController,
                            decoration:
                                InputDecoration(labelText: 'Max Attempts'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: _feedbackController,
                            decoration: InputDecoration(labelText: 'Feedback'),
                          ),
                          TextField(
                            controller: _instructionController,
                            decoration:
                                InputDecoration(labelText: 'Instructions'),
                          ),
                          SwitchListTile(
                            title: Text('Enable Timer'),
                            value: _hasTimer,
                            onChanged: (value) {
                              setState(() {
                                _hasTimer = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _updateAssessment,
                            child: Text('Update'),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }
}
