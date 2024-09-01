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
  final TextEditingController _timeLimitController = TextEditingController();
  final TextEditingController _maxAttemptsController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();

  String _selectedType = '';
  String _selectedQuestionBank = '';
  bool _hasTimer = false;
  bool _isLoading = true;
  String _errorMessage = '';

  List<Map<String, dynamic>> _questions = [];
  List<String> _assessmentTypes = [];
  List<String> _questionBanks = [];

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
          _selectedType = data['type'] ?? '';
          _selectedQuestionBank = data['questionBank'] ?? '';
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
        _assessmentTypes = typesSnapshot.docs
            .map((doc) => doc['type'] as String) // Ensure the type is String
            .toList();
        _questionBanks = banksSnapshot.docs
            .map((doc) => doc['name'] as String) // Ensure the type is String
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

  void _updateAssessment() {
    if (_titleController.text.isEmpty || _selectedType.isEmpty) {
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
      'questionBank':
          _selectedQuestionBank.isNotEmpty ? _selectedQuestionBank : null,
      'questions': _questions,
      'timeLimit': int.tryParse(_timeLimitController.text) ?? 0,
      'maxAttempts': int.tryParse(_maxAttemptsController.text) ?? 0,
      'feedback':
          _feedbackController.text.isNotEmpty ? _feedbackController.text : null,
      'instructions': _instructionController.text.isNotEmpty
          ? _instructionController.text
          : null,
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
                                _selectedType = value!;
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
                                _selectedQuestionBank = value!;
                              });
                            },
                            decoration:
                                InputDecoration(labelText: 'Question Bank'),
                          ),
                          Column(
                            children: _questions
                                .asMap()
                                .entries
                                .map(
                                  (entry) => Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: entry.value['text'],
                                          items: _questions
                                              .map((q) =>
                                                  DropdownMenuItem<String>(
                                                    value: q['text'],
                                                    child: Text(q['text']),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _questions[entry.key]['text'] =
                                                  value!;
                                            });
                                          },
                                          decoration: InputDecoration(
                                              labelText:
                                                  'Question ${entry.key + 1}'),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            _questions.removeAt(entry.key);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
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
