import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'question_creation_page.dart';
import 'question_edit.dart';

class QuestionBankPage extends StatefulWidget {
  final String questionBankId;

  QuestionBankPage({required this.questionBankId});

  @override
  _QuestionBankPageState createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  String _selectedType = 'All';
  String _selectedDifficulty = 'All';
  String _selectedSubject = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question Bank'),
        actions: [
          IconButton(
            icon: Icon(Icons.import_export),
            onPressed: () {
              _showImportExportDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by keyword',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: ['All', 'MCQ', 'True/False', 'Essay']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Filter by Type'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    items: ['All', 'Easy', 'Medium', 'Hard']
                        .map((difficulty) => DropdownMenuItem(
                              value: difficulty,
                              child: Text(difficulty),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value!;
                      });
                    },
                    decoration:
                        InputDecoration(labelText: 'Filter by Difficulty'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    items: ['All', 'Math', 'Science', 'History']
                        .map((subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value!;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Filter by Subject'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final questions = snapshot.data!.docs.where((question) {
                  return _searchQuery.isEmpty ||
                      question['text']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                }).toList();

                if (questions.isEmpty) {
                  return Center(child: Text('No questions found.'));
                }

                return ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    var question = questions[index];
                    return ListTile(
                      title: Text(question['text']),
                      subtitle: Text(
                          'Type: ${question['type']}, Difficulty: ${question['difficulty']}, Subject: ${question['subject']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuestionEditPage(
                                    questionBankId: widget.questionBankId,
                                    questionId: question.id,
                                    questionText: question['text'],
                                    questionType: question['type'],
                                    questionDifficulty: question['difficulty'],
                                    questionSubject: question['subject'],
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('questionBanks')
                                  .doc(widget.questionBankId)
                                  .collection('questions')
                                  .doc(question.id)
                                  .delete();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionCreationPage(
                questionBankId: widget.questionBankId,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Query _buildQuery() {
    Query query = FirebaseFirestore.instance
        .collection('questionBanks')
        .doc(widget.questionBankId)
        .collection('questions');

    if (_selectedType != 'All') {
      query = query.where('type', isEqualTo: _selectedType);
    }
    if (_selectedDifficulty != 'All') {
      query = query.where('difficulty', isEqualTo: _selectedDifficulty);
    }
    if (_selectedSubject != 'All') {
      query = query.where('subject', isEqualTo: _selectedSubject);
    }

    return query;
  }

  void _showImportExportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Import/Export'),
          content: Text('Choose an action:'),
          actions: [
            TextButton(
              onPressed: () {
                exportQuestions();
                Navigator.pop(context);
              },
              child: Text('Export Questions'),
            ),
            TextButton(
              onPressed: () {
                importQuestions();
                Navigator.pop(context);
              },
              child: Text('Import Questions'),
            ),
          ],
        );
      },
    );
  }

  void exportQuestions() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('questionBanks')
        .doc(widget.questionBankId)
        .collection('questions')
        .get();

    List<List<dynamic>> rows = [];
    rows.add(['Text', 'Type', 'Difficulty', 'Subject']); // Header row

    for (var question in snapshot.docs) {
      rows.add([
        question['text'],
        question['type'],
        question['difficulty'],
        question['subject'],
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/questions.csv';
    File file = File(path);
    await file.writeAsString(csv);

    // Optionally, share the file or handle it further
    // SocialShare.shareFile(file);
  }

  void importQuestions() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final input = file.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      for (var row in fields.skip(1)) {
        // Skip header
        await FirebaseFirestore.instance
            .collection('questionBanks')
            .doc(widget.questionBankId)
            .collection('questions')
            .add({
          'text': row[0],
          'type': row[1],
          'difficulty': row[2],
          'subject': row[3],
        });
      }
    }
  }
}
