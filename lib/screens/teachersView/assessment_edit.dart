import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../questionBank/question_creation_page.dart'; // Import your QuestionCreationPage

class AssessmentEditPage extends StatefulWidget {
  final String assessmentId;

  AssessmentEditPage({required this.assessmentId});

  @override
  _AssessmentEditPageState createState() => _AssessmentEditPageState();
}

class _AssessmentEditPageState extends State<AssessmentEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _timeLimitController = TextEditingController();
  final TextEditingController _maxAttemptsController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();

  String? _selectedType;
  String? _selectedQuestionBank;
  List<Map<String, dynamic>> _questions = [];
  List<String> _assessmentTypes = [];
  List<String> _questionBanks = [];
  final Map<String, List<TextEditingController>> _optionControllers = {};

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
        _assessmentTypes = typesSnapshot.docs
            .map((doc) => doc['type'] as String)
            .toSet()
            .toList();
        _questionBanks = banksSnapshot.docs
            .map((doc) =>
                doc.id) // Assuming question bank IDs are stored as doc IDs
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
      Map<String, dynamic> question = {
        'id': '${_questions.length}_${_questionController.text}',
        'text': _questionController.text,
        'type': _selectedType,
        'correctAnswer': '',
        'feedback': _feedbackController.text,
        'options': [],
      };

      // Add options based on type
      if (_selectedType == 'Multiple-choice') {
        question['options'] = _optionControllers[_questionController.text]
                ?.map((controller) => controller.text)
                .toList() ??
            [];
      } else if (_selectedType == 'True/False') {
        question['options'] = ['True', 'False'];
      }

      setState(() {
        _questions.add(question);
        _questionController.clear();
        _optionControllers.remove(_questionController.text);
      });
    }
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _updateAssessment() {
    if (_formKey.currentState!.validate()) {
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
  }

  Widget _buildOptionsField(String questionId) {
    if (!_optionControllers.containsKey(questionId)) {
      _optionControllers[questionId] = [TextEditingController()];
    }

    List<TextEditingController> controllers = _optionControllers[questionId]!;

    return Column(
      children: [
        ...controllers.map(
          (controller) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Option',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      controllers.remove(controller);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              controllers.add(TextEditingController());
            });
          },
          child: Text('Add Option'),
        ),
      ],
    );
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
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration:
                                InputDecoration(labelText: 'Assessment Title'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
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
                            decoration:
                                InputDecoration(labelText: 'Assessment Type'),
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
                                _selectQuestionFromBank(); // Auto-add questions from selected bank
                              });
                            },
                            decoration:
                                InputDecoration(labelText: 'Question Bank'),
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
                          if (_selectedType == 'Multiple-choice')
                            _buildOptionsField(_questionController.text),
                          SizedBox(height: 10),
                          Expanded(
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
                          TextFormField(
                            controller: _timeLimitController,
                            decoration: InputDecoration(
                                labelText: 'Time Limit (minutes)'),
                            keyboardType: TextInputType.number,
                          ),
                          TextFormField(
                            controller: _maxAttemptsController,
                            decoration:
                                InputDecoration(labelText: 'Max Attempts'),
                            keyboardType: TextInputType.number,
                          ),
                          TextFormField(
                            controller: _feedbackController,
                            decoration: InputDecoration(labelText: 'Feedback'),
                          ),
                          TextFormField(
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
                            child: Text('Update Assessment'),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }

  void _selectQuestionFromBank() async {
    if (_selectedQuestionBank != null &&
        _selectedQuestionBank != 'Select a question bank') {
      final questionsSnapshot = await FirebaseFirestore.instance
          .collection('questionBanks')
          .doc(_selectedQuestionBank!)
          .collection('questions')
          .get();

      setState(() {
        _questions.addAll(questionsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'text': data['text'] ?? '',
            'type': data['type'] ?? 'Multiple-choice',
            'correctAnswer': data['correctAnswer'] ?? '',
            'feedback': data['feedback'] ?? '',
            'options': data['options'] ?? [],
          };
        }).toList());
      });
    }
  }
}
