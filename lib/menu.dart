// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, unused_import, use_key_in_widget_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp2/profile.dart';
import 'package:fyp2/tutorial.dart';
import 'feedback.dart';
import 'game/hashi/hashi.dart';
import 'leaderboard.dart';

class MainMenu extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user_details')
              .doc(user.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('');
            }
            if (snapshot.hasError) {
              return Text('');
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            var username = userData['username'] ?? 'Not specified';
            var level = userData['Level'] ?? 'Not specified';
            return Center(child: Text('$username     Lv. $level'));
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Sign Out'),
                      content: Text('Are you sure you want to sign out?'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Sign Out'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('No'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to Bridges Puzzle Game!',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Solve puzzles, challenge your friends, and climb to the top of the leaderboard!',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tutorial or Help Section
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: Card(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Tutorial or Help Section',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Learn how to play the game, tips & tricks.',
                          ),
                          SizedBox(height: 10.0),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TutorialPage()),
                              );
                            },
                            child: Text('Learn More'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Top 3 Players and User Profile sections

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LeaderboardPage()), // Navigate to leaderboard page
                    );
                  },
                  child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Center(
                            child: Text(
                              'Top 3 Players',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('user_details')
                              .orderBy('Level', descending: true)
                              .limit(3)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            var leaderboardData = snapshot.data!.docs;
                            return Column(
                              children: [
                                for (var i = 0; i < leaderboardData.length; i++)
                                  ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'No.${i + 1}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          '${leaderboardData[i]['username']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .black, // Example of styling the font differently
                                          ),
                                        ),
                                        Text(
                                          'Lv. ${leaderboardData[i]['Level']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors
                                                .black, // Example of styling the font differently
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Feedback and Support
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: Card(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Feedback and Support',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Have a suggestion, found a bug, or need assistance? Let us know!',
                          ),
                          SizedBox(height: 10.0),
                          ElevatedButton(
                            onPressed: () {
                              // Implement feedback and support functionality
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FeedbackPage()), // Navigate to leaderboard page
                              );
                            },
                            child: Text('Contact Support'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MainMenu()), // Navigate to your puzzle game page
                  );
                },
                icon: Icon(Icons.home),
              ),
            ),
            Expanded(
              child:
                  SizedBox(), // Empty SizedBox to create space between buttons
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage()), // Navigate to your puzzle game page
                  );
                },
                icon: Icon(Icons.account_circle),
              ),
            ),
          ],
        ),
        shape: CircularNotchedRectangle(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HashiGamePage()), // Navigate to your puzzle game page
          );
        },
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
