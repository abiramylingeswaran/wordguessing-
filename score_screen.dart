import 'package:flutter/material.dart';

class ScoreBoardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> scoreBoard;

  const ScoreBoardScreen({required this.scoreBoard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scoreboard"),
        backgroundColor: Colors.blue,
      ),
      body: scoreBoard.isEmpty
          ? Center(
              child: Text("No scores yet!", style: TextStyle(fontSize: 18)))
          : ListView.builder(
              itemCount: scoreBoard.length,
              itemBuilder: (context, index) {
                final entry = scoreBoard[index];
                return ListTile(
                  leading: CircleAvatar(child: Text("${index + 1}")),
                  title: Text("Word: ${entry['word']}"),
                  subtitle: Text("Score: ${entry['score']}"),
                );
              },
            ),
    );
  }
}   