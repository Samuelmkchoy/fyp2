// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, use_key_in_widget_constructors, file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
