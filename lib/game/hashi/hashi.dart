// ignore_for_file: prefer_const_constructors, duplicate_ignore, avoid_print, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp2/menu.dart';

class HashiGamePage extends StatefulWidget {
  @override
  _HashiGamePageState createState() => _HashiGamePageState();
}

class _HashiGamePageState extends State<HashiGamePage> {
  final user = FirebaseAuth.instance.currentUser!;

  late Timer _timer;
  int _secondsElapsed = 0;
  List<Island> islands = [];
  List<Island> selectedIslands = [];
  String islandInfo = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
    fetchPuzzleData();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          _secondsElapsed++;
        });
      },
    );
  }

  void fetchPuzzleData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('puzzleData').get();
      if (querySnapshot.docs.isNotEmpty) {
        int randomIndex = Random().nextInt(querySnapshot.docs.length);
        List<List<int>> puzzleDataList = querySnapshot.docs[randomIndex]
                ['puzzle']
            .map<List<int>>((dynamic item) => (item as String)
                .split(', ')
                .map<int>((String number) => int.parse(number))
                .toList())
            .toList();
        setupPuzzle(puzzleDataList);
      }
    } catch (e) {
      print('Error fetching puzzle data: $e');
    }
  }

  void setupPuzzle(List<List<int>> puzzleData) {
    islands.clear();
    selectedIslands.clear();

    for (int i = 0; i < puzzleData.length; i++) {
      for (int j = 0; j < puzzleData[i].length; j++) {
        if (puzzleData[i][j] > 0) {
          Offset position = Offset(40 + j * 80, 40 + i * 80);
          islands.add(Island(position: position, value: puzzleData[i][j]));
        }
      }
    }
  }

  bool checkWin() {
    for (var island in islands) {
      if (island.numberOfConnections != island.value) {
        return false;
      }
    }
    return true;
  }

  void newPuzzle() {
    fetchPuzzleData();
    _secondsElapsed = 0;
  }

  void resetGame() {
    setState(() {
      selectedIslands.clear();
      islandInfo = '';
      // Remove all connections between islands
      for (var island in islands) {
        island.connections.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  islandInfo,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Text('Timer: $_secondsElapsed s'),
                SizedBox(height: 20),
                GestureDetector(
                  onTapUp: (tapDetails) {
                    Offset tapPosition = tapDetails.localPosition;
                    for (var island in islands) {
                      if ((tapPosition - island.position).distanceSquared <
                          1600) {
                        setState(() {
                          if (selectedIslands.isEmpty) {
                            selectedIslands.add(island);
                            islandInfo =
                                'Tapped Island: ${island.value} (${island.numberOfConnections})';
                          } else if (selectedIslands.length == 1 &&
                              selectedIslands[0] != island &&
                              !selectedIslands[0]
                                  .connections
                                  .contains(island) &&
                              (island.position.dx ==
                                      selectedIslands[0].position.dx ||
                                  island.position.dy ==
                                      selectedIslands[0].position.dy) &&
                              !hasIslandsBetween(selectedIslands[0], island)) {
                            selectedIslands[0].connections.add(island);
                            island.connections.add(selectedIslands[0]);
                            selectedIslands.clear();
                            islandInfo =
                                'Connected Island: ${island.value} (${island.numberOfConnections})';
                          } else if (selectedIslands.length == 1 &&
                              selectedIslands[0] != island &&
                              selectedIslands[0].connections.contains(island)) {
                            // Toggle double bridge
                            if (selectedIslands[0]
                                    .connections
                                    .where((conn) => conn == island)
                                    .length ==
                                1) {
                              selectedIslands[0].connections.add(island);
                              island.connections.add(selectedIslands[0]);
                            } else {
                              selectedIslands[0].connections.remove(island);
                              island.connections.remove(selectedIslands[0]);
                            }
                            islandInfo =
                                'Toggled Double Bridge: ${island.value} (${island.numberOfConnections})';
                            selectedIslands.clear();
                          }
                        });
                        break;
                      }
                    }
                  },
                  child: CustomPaint(
                    size: Size(400, 400),
                    painter: HashiPainter(
                      islands: islands,
                      selectedIslands: selectedIslands,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, // Align buttons evenly in the row
                  children: [
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: newPuzzle,
                        child: Text('New Puzzle'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: resetGame,
                        child: Text('Reset Game'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (checkWin()) {
                            FirebaseFirestore.instance
                                .collection('user_details')
                                .doc(user.email)
                                .update({'Level': FieldValue.increment(1)});
                            _timer.cancel();
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Congratulations!'),
                                  content: Text('You solved the puzzle!'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HashiGamePage()),
                                        );
                                      },
                                      // ignore: prefer_const_constructors
                                      child: Text('Next Puzzle'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MainMenu()),
                                        );
                                      },
                                      child: Text('Back to Menu'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Try Again'),
                                  content:
                                      Text('The puzzle is not yet solved.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Text('Done'),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainMenu()),
          );
        },
        child: Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }

  bool hasIslandsBetween(Island startIsland, Island endIsland) {
    double startX = startIsland.position.dx;
    double startY = startIsland.position.dy;
    double endX = endIsland.position.dx;
    double endY = endIsland.position.dy;

    if (startX == endX) {
      double minY = min(startY, endY);
      double maxY = max(startY, endY);
      for (var island in islands) {
        if (island.position.dx == startX &&
            island.position.dy > minY &&
            island.position.dy < maxY) {
          return true;
        }
      }
    } else if (startY == endY) {
      double minX = min(startX, endX);
      double maxX = max(startX, endX);
      for (var island in islands) {
        if (island.position.dy == startY &&
            island.position.dx > minX &&
            island.position.dx < maxX) {
          return true;
        }
      }
    }
    return false;
  }
}

class Island {
  final Offset position;
  int value;
  List<Island> connections;

  Island({
    required this.position,
    required this.value,
  }) : connections = [];

  int get numberOfConnections {
    return connections.length;
  }
}

class HashiPainter extends CustomPainter {
  final List<Island> islands;
  final List<Island> selectedIslands;

  HashiPainter({required this.islands, required this.selectedIslands});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint islandPaint = Paint()..color = Colors.blue;
    final Paint singleLinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;
    final Paint doubleLinePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 6; // Adjust the width for double bridges
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw connections
    for (var island in islands) {
      for (var connection in island.connections) {
        // Use different line paints based on the number of connections
        Paint linePaint =
            island.connections.where((conn) => conn == connection).length == 1
                ? singleLinePaint
                : doubleLinePaint;
        canvas.drawLine(
          island.position,
          connection.position,
          linePaint,
        );
      }
    }

    // Draw islands
    for (var island in islands) {
      canvas.drawCircle(island.position, 30, islandPaint);
      textPainter.text = TextSpan(
        text: '${island.value} (${island.numberOfConnections})',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        island.position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Draw selected islands
    for (var island in selectedIslands) {
      canvas.drawCircle(island.position, 30, Paint()..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
