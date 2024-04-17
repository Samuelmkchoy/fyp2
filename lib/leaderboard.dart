// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ignore: prefer_const_constructors
        title: Text('Leaderboard'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user_details').orderBy('Level', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          var leaderboardData = snapshot.data!.docs;
          return ListView.builder(
            itemCount: leaderboardData.length,
            itemBuilder: (context, index) {
              var entry = leaderboardData[index];
              var username = entry['username'];
              var level = entry['Level'];
              return Card(
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('No. ${index + 1}'),
                      Text('$username'),
                      Text('Lv. $level'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
