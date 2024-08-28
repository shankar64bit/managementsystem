import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../studentView/assessment_taking.dart';
import 'assessment_edit.dart';

class AssessmentDetailPage extends StatelessWidget {
  final String assessmentId;

  AssessmentDetailPage({required this.assessmentId});

  @override
  Widget build(BuildContext context) {
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
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final assessment = snapshot.data!.data() as Map<String, dynamic>;
          final assessmentTitle = assessment['title'] ?? 'No Title';
          final instructions = assessment['instructions'] ?? 'No Instructions';
          final hasTimer = assessment['hasTimer'] ?? false;
          final timeLimit = (assessment['timeLimit'] as int?) ?? 0;

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
                  'Type: ${assessment['type']}',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 10),
                // Question Bank
                Text(
                  'Question Bank: ${assessment['questionBank']}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                // Questions
                Text(
                  'Questions: ${assessment['questions']}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                // Time Limit
                Text(
                  'Time Limit: ${timeLimit} minutes',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                // Max Attempts
                Text(
                  'Max Attempts: ${assessment['maxAttempts']}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                // Feedback
                Text(
                  'Feedback: ${assessment['feedback']}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                // Instructions
                Text(
                  'Instructions: ${assessment['instructions']}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Edit Button
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                                  'Are you sure you want to delete this assessment?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('assessments')
                                        .doc(assessmentId)
                                        .delete();
                                    Navigator.pop(
                                        context); // Go back to the dashboard
                                  },
                                  child: Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // Take Assessment Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssessmentTakingPage(
                              assessmentTitle: assessmentTitle,
                              instructions: instructions,
                              hasTimer: hasTimer,
                              timeLimit: Duration(minutes: timeLimit),
                            ),
                          ),
                        );
                      },
                      child: Text('Take Assessment'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
