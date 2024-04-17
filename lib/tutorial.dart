// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, unused_import, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class TutorialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutorial'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the Bridges Puzzle Game Tutorial!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '1. Objective:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'The objective of the game is to connect all the islands with bridges according to the given rules.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '2. Rules:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              ' - Each island must be connected to exactly one other island.\n'
              ' - The number on each island indicates how many bridges it must have connected to it.\n'
              ' - The bridges must follow the horizontal or vertical path and cannot cross each other.\n'
              ' - The number of bridges between two islands cannot exceed the number on each island.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '3. How to Play:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              ' - Tap on an island to select it.\n'
              ' - Tap on another island to connect them with a bridge.\n'
              ' - Tap on a selected island again to double it.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '4. Tips:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              ' - Start by connecting islands with the fewest bridges required.\n'
              ' - Use the numbers on the islands to plan your bridge connections.\n'
              ' - Remember that each island must have the exact number of bridges required.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
