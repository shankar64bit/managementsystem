import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StudentAssignmentHistoryPage extends StatefulWidget {
  @override
  _StudentAssignmentHistoryPageState createState() =>
      _StudentAssignmentHistoryPageState();
}

class _StudentAssignmentHistoryPageState
    extends State<StudentAssignmentHistoryPage> {
  final User? studentUser =
      FirebaseAuth.instance.currentUser; // Get current user
  String _searchQuery = '';
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignment History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Information Card
            _buildUserInformationCard(),
            SizedBox(height: 16.0),

            // Search Bar
            _buildSearchBar(),
            SizedBox(height: 10), // Space between search bar and list

            // StreamBuilder to display assignments
            Expanded(
              child: _buildAssignmentList(),
            ),
          ],
        ),
      ),
    );
  }

  // Function to safely get the initials or fallback to a default value
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) {
      return '?'; // Fallback character when displayName is null or empty
    }
    return name[0].toUpperCase();
  }

  Widget _buildUserInformationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(
                _getInitials(studentUser?.displayName),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${studentUser?.displayName ?? ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    '${studentUser?.email ?? ''}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search by title or status...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildAssignmentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .doc(studentUser!.uid)
          .collection('assessments')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error fetching assignments.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No assignment history found for your account.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final assignments = snapshot.data!.docs;

        // Filter assignments based on search query and selected status
        final filteredAssignments = assignments.where((assignment) {
          final statusMatches = (assignment['status'] as String)
              .toLowerCase()
              .contains(_searchQuery);
          final statusFilterMatches = _selectedStatus == 'All' ||
              assignment['status'] == _selectedStatus;
          return statusMatches && statusFilterMatches;
        }).toList();

        // Handle empty filtered list
        if (filteredAssignments.isEmpty) {
          return Center(
            child: Text(
              'No assignments match your search criteria.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredAssignments.length,
          itemBuilder: (context, index) {
            var assignment = filteredAssignments[index];
            var submittedAt = assignment['submittedAt'] != null
                ? DateFormat('yyyy-MM-dd HH:mm')
                    .format(assignment['submittedAt'].toDate())
                : 'Not submitted';

            // Ensure title fetching is safe
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('assessments')
                  .doc(assignment.id)
                  .get(),
              builder: (context, titleSnapshot) {
                if (titleSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!titleSnapshot.hasData || !titleSnapshot.data!.exists) {
                  return ListTile(
                    title: Text('Assessment Title Not Found'),
                    subtitle: Text('Assessment ID: ${assignment.id}'),
                  );
                }

                var assessmentData =
                    titleSnapshot.data!.data() as Map<String, dynamic>;
                var assessmentTitle =
                    assessmentData['title'] ?? 'Untitled Assessment';

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ExpansionTile(
                    title: Text('Title: $assessmentTitle'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Submitted on: $submittedAt'),
                        Text('Status: ${assignment['status']}'),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Details:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            _buildDetails(assignment),
                            SizedBox(height: 8),
                            Text(
                              'Answers:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            _buildAnswers(assignment['answers'] ?? {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Build a list of details for each assignment
  Widget _buildDetails(DocumentSnapshot assignment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ID: ${assignment.id}'),
        if (assignment['submittedBy'] != null)
          Text('Submitted-By: ${assignment['submittedBy']}'),
        // if (assignment['score'] != null) Text('Score: ${assignment['score']}'),
        // if (assignment['maxScore'] != null)
        //   Text('Max Score: ${assignment['maxScore']}'),
        // if (assignment['timeTaken'] != null)
        //   Text('Time Taken: ${assignment['timeTaken']} minutes'),
      ],
    );
  }

  // Build a list of answers with field names and values
  Widget _buildAnswers(Map<String, dynamic> answers) {
    if (answers.isEmpty) {
      return Text('No answers available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: answers.entries.map((entry) {
        return Text('${entry.key}: ${entry.value}');
      }).toList(),
    );
  }
}
