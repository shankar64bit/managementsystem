import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:managementsystem/screens/studentView/assessment_taking.dart';

import 'assessment_creation.dart';
import 'assessment_detail.dart';
import '../user/login_page.dart';

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

  final List<Widget> _pages = [
    AssessmentDashboard(), // Current page
    Page(), // Student View page
    Page(), // Assessment Creation page
    Page(), // Profile page or another page
  ];

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
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to the selected page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _pages[_selectedIndex]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Assessment Dashboard'),
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
                      items: ['All', 'Quiz', 'Assignment', 'Survey']
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
                  final assessments = snapshot.data!.docs;

                  // Filter assessments based on search query and selected type
                  final filteredAssessments = assessments.where((assessment) {
                    final titleMatches = assessment['title']
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery);
                    final typeMatches = _selectedType == 'All' ||
                        assessment['type'] == _selectedType;
                    return titleMatches && typeMatches;
                  }).toList();

                  // Sort filtered assessments based on selected sort option
                  if (_selectedSort == 'Date') {
                    filteredAssessments.sort((a, b) =>
                        (a['createdAt'] as Timestamp)
                            .compareTo(b['createdAt'] as Timestamp));
                  } else if (_selectedSort == 'Popularity') {
                    filteredAssessments.sort((a, b) => (b['popularity'] as int)
                        .compareTo(a['popularity'] as int));
                  } else if (_selectedSort == 'Completion Rate') {
                    filteredAssessments.sort((a, b) =>
                        (b['completionRate'] as double)
                            .compareTo(a['completionRate'] as double));
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
                          title: Text(assessment['title']),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(assessment['type']),
                              Text(assessment['id']),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AssessmentDetailPage(
                                      assessmentId: assessment.id)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AssessmentCreationPage()),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
            backgroundColor: Colors.deepPurple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'Student View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.white,
      ),
    );
  }
}

class Page extends StatelessWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Sample'),
      ),
      body: Container(
        color: Colors.amber,
      ),
    );
  }
}
