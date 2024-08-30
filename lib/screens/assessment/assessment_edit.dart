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

  bool _hasTimer = false; // Track whether the assessment has a timer
  bool _isLoading = true; // Loading state for fetching assessment data
  String _errorMessage = ''; // To display error messages

  @override
  void initState() {
    super.initState();
    _fetchAssessment();
  }

  Future<void> _fetchAssessment() async {
    try {
      DocumentSnapshot assessment = await FirebaseFirestore.instance
          .collection('assessments')
          .doc(widget.assessmentId)
          .get();

      if (assessment.exists) {
        // Fetching fields from Firestore
        Map<String, dynamic> data = assessment.data() as Map<String, dynamic>;
        _titleController.text = data['title'] ?? '';
        _typeController.text = data['type'] ?? '';
        _questionBankController.text = data['questionBank'] ?? '';

        // Handle questions as a list
        if (data['questions'] is List) {
          _questionsController.text = (data['questions'] as List).join(', ');
        } else {
          _questionsController.text = data['questions'] ?? '';
        }

        _timeLimitController.text = data['timeLimit']?.toString() ?? '';
        _maxAttemptsController.text = data['maxAttempts']?.toString() ?? '';
        _feedbackController.text = data['feedback'] ?? '';
        _instructionController.text = data['instructions'] ?? '';
        _hasTimer = data['hasTimer'] ?? false;
      } else {
        _errorMessage = 'Assessment not found.';
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to fetch assessment: $error';
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading indicator
      });
    }
  }

  void _updateAssessment() {
    if (_titleController.text.isEmpty || _typeController.text.isEmpty) {
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
      'hasTimer': _hasTimer,
    }).then((_) {
      Navigator.pop(context); // Go back to the detail page
    }).catchError((error) {
      // Handle any errors here
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
                  ? Center(child: Text(_errorMessage))
                  : SingleChildScrollView(
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
                            decoration:
                                InputDecoration(labelText: 'Question Bank'),
                          ),
                          TextField(
                            controller: _questionsController,
                            decoration: InputDecoration(
                                labelText: 'Questions (comma-separated)'),
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
