import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../studentView/assessment_taking.dart';
import 'assessment_edit.dart';

class AssessmentDetailPage extends StatelessWidget {
  final String assessmentId;

  AssessmentDetailPage({required this.assessmentId});

  @override
  Widget build(BuildContext context) {
    // Fetch the current user's student ID from Firebase Authentication
    final User? user = FirebaseAuth.instance.currentUser;
    final String studentId = user?.uid ?? '';

    // Create a GlobalKey for the AssessmentTakingPage
    final GlobalKey assessmentKey = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assessments')
            .doc(assessmentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(
              child: Text(
                'No data found for this assessment.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          final assessment = snapshot.data!.data() as Map<String, dynamic>;
          final assessmentTitle = assessment['title'] ?? 'No Title';
          final instructions = assessment['instructions'] ?? 'No Instructions';
          final hasTimer = assessment['hasTimer'] ?? false;
          final timeLimit = (assessment['timeLimit'] as int?) ?? 0;
          final questionsCount =
              (assessment['questions'] as List?)?.length ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Title: $assessmentTitle',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                // Type
                Text(
                  'Type: ${assessment['type'] ?? 'Not specified'}',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 10),
                // Question Bank
                Text(
                  'Question Bank: ${assessment['questionBank'] ?? 'None'}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                // Questions Count
                Text(
                  'Questions: $questionsCount questions',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                // Time Limit
                Text(
                  'Time Limit: ${timeLimit > 0 ? '$timeLimit minutes' : 'No limit'}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                // Timer
                Text(
                  'Timer: ${hasTimer ? 'Enabled' : 'Disabled'}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                // Max Attempts
                Text(
                  'Max Attempts: ${assessment['maxAttempts'] ?? 'Unlimited'}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                // Feedback
                Text(
                  'Feedback: ${assessment['feedback'] ?? 'No feedback provided'}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                // Instructions
                Text(
                  'Instructions: ${instructions}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                // Buttons Row

                user!.email == 'admin@gmail.com'
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AssessmentEditPage(
                                          assessmentId: assessmentId)),
                                );
                              },
                              child: Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            // Delete Button
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Confirm Deletion'),
                                      content: Text(
                                          'Are you sure you want to delete this assessment? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close dialog
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('assessments')
                                                .doc(assessmentId)
                                                .delete()
                                                .then((_) {
                                              Navigator.pop(
                                                  context); // Close the dialog
                                              Navigator.pop(
                                                  context); // Go back to the dashboard
                                            }).catchError((error) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Error deleting assessment: $error')),
                                              );
                                            });
                                          },
                                          child: Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ])
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Edit Button

                          // Take Assessment Button
                          ElevatedButton(
                            onPressed: () {
                              if (studentId.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AssessmentTakingPage(
                                      key: assessmentKey,
                                      assessmentId: assessmentId,
                                      studentId: studentId,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'You must be logged in to take an assessment.'),
                                  ),
                                );
                              }
                            },
                            child: Text('Take Assessment'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
