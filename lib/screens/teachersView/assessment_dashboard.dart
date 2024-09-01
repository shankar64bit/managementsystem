import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/assessment.dart';
import 'assessment_creation.dart';
import '../user/login_page.dart';
import 'assessment_detail.dart';

class AssessmentDashboard extends StatefulWidget {
  @override
  _AssessmentDashboardState createState() => _AssessmentDashboardState();
}

class _AssessmentDashboardState extends State<AssessmentDashboard> {
  String _searchQuery = '';
  String _selectedType = 'All';
  String _selectedSort = 'Date'; // Default sorting option
  String _error = '';
  int _selectedIndex = 0;

  // Define colors for dropdowns
  final Color dropdownColor = Color(0xFFE3F2FD); // Light blue
  final Color dropdownTextColor = Color.fromARGB(226, 0, 0, 0);

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to log out: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            Card(
              elevation: 4,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by title...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
              ),
            ),
            SizedBox(height: 5), // Space between search bar and dropdowns

            // Filter and Sort Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filter Dropdown
                Expanded(
                  child: Card(
                    elevation: 2,
                    color: dropdownColor,
                    child: DropdownButton<String>(
                      value: _selectedType,
                      items: [
                        'All',
                        'Multiple-choice',
                        'Short answer',
                        'Essay',
                        'True/False'
                      ]
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Center(
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: dropdownTextColor,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                      underline: SizedBox(), // Remove underline
                      isExpanded: true,
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child:
                            Icon(Icons.filter_list, color: dropdownTextColor),
                      ),
                    ),
                  ),
                ),

                // Sort Dropdown
                Card(
                  elevation: 2,
                  color: dropdownColor,
                  child: Container(
                    width: 150, // Fixed width for better alignment
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      items: ['Date', 'Popularity', 'Completion Rate']
                          .map((sortOption) => DropdownMenuItem(
                                value: sortOption,
                                child: Center(
                                  child: Text(
                                    sortOption,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: dropdownTextColor,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value!;
                        });
                      },
                      underline: SizedBox(), // Remove underline
                      isExpanded: true,
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.sort, color: dropdownTextColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // StreamBuilder to display assessments
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('assessments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final assessments = snapshot.data!.docs
                      .map((doc) => Assessment.fromMap(
                          doc.data() as Map<String, dynamic>))
                      .toList();

                  // Filter assessments based on search query and selected type
                  final filteredAssessments = assessments.where((assessment) {
                    final titleMatches =
                        assessment.title.toLowerCase().contains(_searchQuery);
                    final typeMatches = _selectedType == 'All' ||
                        assessment.type == _selectedType;
                    return titleMatches && typeMatches;
                  }).toList();

                  // Sort filtered assessments based on selected sort option
                  if (_selectedSort == 'Date') {
                    filteredAssessments
                        .sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  } else if (_selectedSort == 'Popularity') {
                    filteredAssessments.sort((a, b) =>
                        (b.popularity ?? 0).compareTo(a.popularity ?? 0));
                  } else if (_selectedSort == 'Completion Rate') {
                    filteredAssessments.sort((a, b) => (b.completionRate ?? 0.0)
                        .compareTo(a.completionRate ?? 0.0));
                  }

                  return ListView.builder(
                    itemCount: filteredAssessments.length,
                    itemBuilder: (context, index) {
                      var assessment = filteredAssessments[index];
                      return Card(
                        elevation: 2,
                        margin:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                        child: ListTile(
                          title: Text(assessment.title),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(assessment.type),
                              Text(DateFormat('(dd-MM-yyyy) HH:MMa')
                                  .format(assessment.createdAt.toDate())),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssessmentDetailPage(
                                  assessmentId: assessment.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AssessmentCreationPage()),
          );
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Minimum size
          children: [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Create',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
