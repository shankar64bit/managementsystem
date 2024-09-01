import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssessmentTakingPage extends StatefulWidget {
  final String assessmentId;
  final String studentId;

  const AssessmentTakingPage({
    Key? key,
    required this.assessmentId,
    required this.studentId,
  }) : super(key: key);

  @override
  _AssessmentTakingPageState createState() => _AssessmentTakingPageState();
}

class _AssessmentTakingPageState extends State<AssessmentTakingPage> {
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;
  bool _showFeedback = false;
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  Map<String, dynamic> _studentAnswers = {};
  Map<String, dynamic>? _assessment;
  List<Map<String, dynamic>> _questions = [];
  Map<String, TextEditingController> _textControllers = {};
  User? _currentUser;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchAssessment();
    _startAutoSaveTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoSaveTimer?.cancel();
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to take the assessment.')),
      );
      // Navigate to login page here
    }
  }

  Future<void> _fetchAssessment() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('assessments')
          .doc(widget.assessmentId)
          .get();

      final assessmentData = snapshot.data() as Map<String, dynamic>?;

      if (assessmentData != null) {
        final questionsData = assessmentData['questions'];
        if (questionsData is List) {
          _questions = List<Map<String, dynamic>>.from(
            questionsData
                .where((q) => q is Map<String, dynamic> && q['id'] != null),
          );

          for (var question in _questions) {
            String questionId = question['id'];
            if (!_textControllers.containsKey(questionId)) {
              _textControllers[questionId] = TextEditingController();
            }
          }
        }

        if (assessmentData['hasTimer'] == true) {
          _remainingTime = Duration(minutes: assessmentData['timeLimit'] ?? 0);
          _startTimer();
        }

        setState(() {
          _assessment = assessmentData;
        });

        await _loadExistingAnswers();
      }
    } catch (e) {
      print("Error fetching assessment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load assessment. Please try again.')),
      );
    }
  }

  Widget _buildMultipleChoiceQuestion(Map<String, dynamic> question) {
    List<dynamic> options = question['options'] ?? [];
    String questionId = question['id'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question['text'] ?? 'No question text',
            style: TextStyle(fontSize: 18)),
        ...options.map((option) => RadioListTile<String>(
              title: Text(option.toString()),
              value: option.toString(),
              groupValue: _studentAnswers[questionId],
              onChanged: (value) => _updateAnswer(questionId, value),
            )),
      ],
    );
  }

  Future<void> _loadExistingAnswers() async {
    try {
      DocumentSnapshot answersSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('assessments')
          .doc(widget.assessmentId)
          .get();

      if (answersSnapshot.exists) {
        final answersData = answersSnapshot.data() as Map<String, dynamic>?;
        if (answersData != null && answersData.containsKey('answers')) {
          setState(() {
            _studentAnswers = Map<String, dynamic>.from(answersData['answers']);
          });
          _updateTextControllers();
        }
      }
    } catch (e) {
      print("Error loading existing answers: $e");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 0) {
        _submitAssessment();
      } else {
        setState(() {
          _remainingTime -= Duration(seconds: 1);
        });
      }
    });
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _saveProgress(showSnackBar: false);
    });
  }

  Widget _buildQuestionView(Map<String, dynamic> question) {
    String? questionId = question['id'] as String?;
    if (questionId == null || questionId.isEmpty) {
      return Text('Error: Question ID is missing. Please contact support.');
    }

    switch (question['type']) {
      case 'Multiple-choice':
        return _buildMultipleChoiceQuestion(question);
      case 'Short answer':
      case 'Essay':
        return _buildShortAnswerQuestion(question);
      case 'True/False':
        return _buildTrueFalseQuestion(question);
      default:
        return Text('Unsupported question type');
    }
  }

  Widget _buildShortAnswerQuestion(Map<String, dynamic> question) {
    String questionId = question['id'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question['text'] ?? 'No question text',
            style: TextStyle(fontSize: 18)),
        TextField(
          controller: _textControllers[questionId],
          onChanged: (value) => _updateAnswer(questionId, value),
          maxLines: question['type'] == 'Essay' ? 5 : 1,
        ),
      ],
    );
  }

  Widget _buildTrueFalseQuestion(Map<String, dynamic> question) {
    String questionId = question['id'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question['text'] ?? 'No question text',
            style: TextStyle(fontSize: 18)),
        RadioListTile<String>(
          title: Text('True'),
          value: 'True',
          groupValue: _studentAnswers[questionId],
          onChanged: (value) => _updateAnswer(questionId, value),
        ),
        RadioListTile<String>(
          title: Text('False'),
          value: 'False',
          groupValue: _studentAnswers[questionId],
          onChanged: (value) => _updateAnswer(questionId, value),
        ),
      ],
    );
  }

  void _updateAnswer(String questionId, dynamic value) {
    setState(() {
      if (value != null && value.toString().isNotEmpty) {
        _studentAnswers[questionId] = value.toString();
      } else {
        _studentAnswers.remove(questionId);
      }
    });
    _saveProgress(showSnackBar: false);
  }

  void _navigateToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
    });
    _updateTextControllers();
  }

  void _updateTextControllers() {
    for (var question in _questions) {
      String questionId = question['id'] as String;
      _textControllers[questionId]?.text = _studentAnswers[questionId] ?? '';
    }
  }

  Future<void> _saveProgress({bool showSnackBar = true}) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('assessments')
          .doc(widget.assessmentId)
          .set({
        'answers': _studentAnswers,
        'progress': _currentQuestionIndex,
        'savedAt': Timestamp.now(),
        'lastUpdatedBy': _currentUser?.uid,
      }, SetOptions(merge: true));

      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Progress saved successfully!')));
      }
    } catch (e) {
      print("Error saving progress: $e");
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save progress. Please try again.')),
        );
      }
    }
  }

  Future<void> _submitAssessment() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('assessments')
          .doc(widget.assessmentId)
          .set({
        'answers': _studentAnswers,
        'submittedAt': Timestamp.now(),
        'status': 'submitted',
        'submittedBy': _currentUser?.uid,
      }, SetOptions(merge: true));

      setState(() {
        _isSubmitting = false;
        _showFeedback = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assessment submitted successfully!')));
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      print("Error submitting assessment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to submit assessment. Please try again.')),
      );
    }
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget _buildQuestionNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: _currentQuestionIndex > 0
              ? () => _navigateToQuestion(_currentQuestionIndex - 1)
              : null,
        ),
        Text(
          'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios),
          onPressed: _currentQuestionIndex < _questions.length - 1
              ? () => _navigateToQuestion(_currentQuestionIndex + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildQuestionIndicators() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          bool isAnswered =
              _studentAnswers.containsKey(_questions[index]['id']);
          bool isCurrent = index == _currentQuestionIndex;

          return GestureDetector(
            onTap: () => _navigateToQuestion(index),
            child: Container(
              width: 30,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? Colors.blue
                    : (isAnswered ? Colors.green : Colors.grey),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_assessment?['title'] ?? ''} - Student: ${_currentUser?.displayName ?? ''}',
          style: TextStyle(fontSize: 15),
        ),
      ),
      body: _assessment == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions: ${_assessment?['instructions'] ?? ''}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (_assessment?['hasTimer'] == true)
                    Text(
                      'Time Remaining: ${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  SizedBox(height: 20),
                  _buildQuestionNavigation(),
                  SizedBox(height: 10),
                  _buildQuestionIndicators(),
                  SizedBox(height: 20),
                  Expanded(
                    child: _questions.isEmpty
                        ? Center(child: Text('No questions available'))
                        : SingleChildScrollView(
                            child: _currentQuestionIndex < _questions.length
                                ? _buildQuestionView(
                                    _questions[_currentQuestionIndex])
                                : Text('Error: Invalid question index'),
                          ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => _saveProgress(showSnackBar: true),
                        child: Text('Save Progress'),
                      ),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitAssessment,
                        child: _isSubmitting
                            ? CircularProgressIndicator()
                            : Text('Submit Assessment'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
