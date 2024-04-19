// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('user_details')
            .doc(user!.email)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          var isAdmin = userData['admin'] ?? false;

          if (isAdmin) {
            return Container(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10.0),
                    Text('Welcome, Admin!'),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminFeedbackPage()),
                        );
                      },
                      child: Text('Feedback Report'),
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InputPuzzlePage()),
                        );
                      },
                      child: Text('Input Puzzle Data'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: Text('You do not have permission to access this page.'),
            );
          }
        },
      ),
    );
  }
}

class AdminFeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Feedback'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          var feedbackList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              var feedback = feedbackList[index];
              var messageId = feedback.id; // Get the document ID
              var email = feedback['email'];
              var message = feedback['message'];
              var isSolved = feedback['isSolved'];
              var timestamp = feedback['timestamp'];

              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$email'),
                    Text('Message: $message'),
                    Text(
                        'Timestamp: ${DateFormat('MMM dd, yyyy hh:mm a').format(timestamp.toDate())}'),
                    Text('Is Solved: ${isSolved ? 'Yes' : 'No'}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to the edit feedback screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditFeedbackPage(messageId: messageId),
                          ),
                        );
                      },
                    ),
                    if (!isSolved)
                      IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () {
                          // Mark feedback as solved
                          FirebaseFirestore.instance
                              .collection('feedback')
                              .doc(messageId)
                              .update({'isSolved': true});
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        // Show delete confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Feedback'),
                            content: Text(
                                'Are you sure you want to delete this feedback?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Delete the feedback from Firestore
                                  FirebaseFirestore.instance
                                      .collection('feedback')
                                      .doc(messageId)
                                      .delete();
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('No'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to the edit feedback screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditFeedbackPage(messageId: messageId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class EditFeedbackPage extends StatefulWidget {
  final String messageId;

  EditFeedbackPage({required this.messageId});

  @override
  _EditFeedbackPageState createState() => _EditFeedbackPageState();
}

class _EditFeedbackPageState extends State<EditFeedbackPage> {
  String editedMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  editedMessage = value;
                });
              },
              decoration: InputDecoration(labelText: 'Enter edited message'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update the feedback message in Firestore
                FirebaseFirestore.instance
                    .collection('feedback')
                    .doc(widget.messageId)
                    .update({'message': editedMessage});
                Navigator.of(context)
                    .pop(); // Navigate back to the admin feedback page
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class InputPuzzlePage extends StatelessWidget {
  final TextEditingController puzzleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Puzzle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: puzzleController,
              decoration: InputDecoration(
                labelText: 'Enter puzzle data',
                hintText: 'e.g.: 4, 0, 3, 0, 2; 4, 3..',
              ),
              maxLines: null, // Allow multiline input
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Get the entered puzzle data
                String puzzleData = puzzleController.text;
                // Split the puzzle data into individual rows
                List<String> rows = puzzleData.split(';');
                // Trim each row to remove leading and trailing spaces
                rows = rows.map((row) => row.trim()).toList();
                // Add puzzleData to Firebase
                await FirebaseFirestore.instance.collection('puzzleData').add({
                  'puzzle': rows,
                });
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Puzzle data added successfully!'),
                ));
              },
              child: Text('Submit Puzzle'),
            ),
          ],
        ),
      ),
    );
  }
}
