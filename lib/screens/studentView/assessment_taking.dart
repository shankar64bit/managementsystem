import 'dart:async';

import 'package:flutter/material.dart';

class AssessmentTakingPage extends StatefulWidget {
  final String assessmentTitle;
  final String instructions;
  final bool hasTimer;
  final Duration timeLimit;

  const AssessmentTakingPage({
    Key? key,
    required this.assessmentTitle,
    required this.instructions,
    this.hasTimer = false,
    this.timeLimit = const Duration(minutes: 30),
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

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the capital of France?',
      'type': 'text',
      'answer': '',
      'feedback': 'The correct answer is Paris.',
    },
    {
      'question': 'What is 2 + 2?',
      'type': 'text',
      'answer': '',
      'feedback': 'The correct answer is 4.',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.hasTimer) {
      _remainingTime = widget.timeLimit;
      _startTimer();
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _navigateToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
    });
  }

  void _saveProgress() {
    // Implement saving progress functionality
  }

  void _submitAssessment() {
    setState(() {
      _isSubmitting = true;
      _showFeedback = true;
    });
    // Implement submission functionality
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assessmentTitle + ' - [Student view]'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions: ${widget.instructions}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.hasTimer)
              Text(
                'Time Remaining: ${_remainingTime.inMinutes}:${_remainingTime.inSeconds % 60}',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1}: ${currentQuestion['question']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  _buildAnswerInputField(currentQuestion),
                  SizedBox(height: 20),
                  if (_showFeedback)
                    Text(
                      'Feedback: ${currentQuestion['feedback']}',
                      style: TextStyle(color: Colors.green, fontSize: 16),
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
      case 'text':
        return TextField(
          onChanged: (value) {
            question['answer'] = value;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your answer here',
          ),
        );
      // Add other question types (e.g., multiple choice, image upload) here
      default:
        return Container();
    }
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
}
