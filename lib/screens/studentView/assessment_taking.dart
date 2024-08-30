import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late Timer _timer;
  late Duration _remainingTime;
  Map<String, dynamic> _studentAnswers = {};
  Map<String, dynamic>? _assessment;
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _fetchAssessment();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
            questionsData.where((q) => q is Map<String, dynamic>),
          );
        } else {
          _questions = [];
        }

        if (assessmentData['hasTimer'] == true) {
          _remainingTime = Duration(minutes: assessmentData['timeLimit'] ?? 0);
          _startTimer();
        }

        setState(() {
          _assessment = assessmentData;
        });
      }
    } catch (e) {
      print("Error fetching assessment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load assessment. Please try again.')),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds == 0) {
        _submitAssessment();
      } else {
        setState(() {
          _remainingTime -= Duration(seconds: 1);
        });
      }
    });
  }

  void _navigateToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
    });
  }

  Future<void> _saveProgress() async {
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
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Progress saved successfully!')));
    } catch (e) {
      print("Error saving progress: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save progress. Please try again.')),
      );
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
      });

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
  }

  Widget _buildQuestionView(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'Multiple Choice':
        return _buildMultipleChoiceQuestion(question);
      case 'Short Answer':
        return _buildShortAnswerQuestion(question);
      default:
        return Text('Unsupported question type');
    }
  }

  Widget _buildMultipleChoiceQuestion(Map<String, dynamic> question) {
    List<dynamic> options = question['options'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.containsKey('media')) _buildMedia(question['media']),
        Text(question['text'], style: TextStyle(fontSize: 18)),
        ...options.map((option) => RadioListTile(
              title: Text(option),
              value: option,
              groupValue: _studentAnswers[question['id']],
              onChanged: (value) {
                setState(() {
                  _studentAnswers[question['id']] = value;
                });
              },
            )),
      ],
    );
  }

  Widget _buildShortAnswerQuestion(Map<String, dynamic> question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.containsKey('media')) _buildMedia(question['media']),
        Text(question['text'], style: TextStyle(fontSize: 18)),
        TextFormField(
          initialValue: _studentAnswers[question['id']] ?? '',
          onChanged: (value) {
            setState(() {
              _studentAnswers[question['id']] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMedia(dynamic media) {
    if (media is String) {
      if (media.endsWith('.jpg') || media.endsWith('.png')) {
        return Image.network(media);
      } else if (media.endsWith('.mp4')) {
        // Implement video player widget for videos
        // return VideoPlayerWidget(url: media);
      }
    }
    return SizedBox.shrink();
  }

  Widget _buildQuestionNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        _questions.length,
        (index) => IconButton(
          icon: Icon(
            index == _currentQuestionIndex
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
          ),
          onPressed: () => _navigateToQuestion(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion =
        _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_assessment?['title'] ?? ''} - [Student view]'),
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
                      'Time Remaining: ${_remainingTime.inMinutes}:${_remainingTime.inSeconds % 60}',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  SizedBox(height: 20),
                  Expanded(
                    child: currentQuestion == null
                        ? Center(child: Text('No questions available'))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildQuestionView(currentQuestion),
                              SizedBox(height: 20),
                              if (_showFeedback &&
                                  currentQuestion.containsKey('feedback'))
                                Text(
                                  'Feedback: ${currentQuestion['feedback']}',
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 16),
                                ),
                            ],
                          ),
                  ),
                  _buildQuestionNavigation(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _saveProgress,
                        child: Text('Save Progress'),
                      ),
                      ElevatedButton(
                        onPressed: _submitAssessment,
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

  Widget _buildAnswerInputField(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'Multiple Choice':
        return _buildMultipleChoiceQuestion(question);
      case 'Short Answer':
        return _buildShortAnswerQuestion(question);
      default:
        return Container();
    }
  }
}
