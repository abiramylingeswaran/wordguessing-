import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Game/home_logic.dart';
import 'score_screen.dart';

class HomeScreen extends StatelessWidget {
  final String playerName;
  HomeScreen({required this.playerName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final logic = HomeLogic();
        logic.fetchNewWord();
        logic.startTimer(() {
          Future.microtask(() {
            if (context.mounted) {
              _showGameOverDialog(context, logic); // Pass logic here
            }
          });
        });
        return logic;
      },
      child: Consumer<HomeLogic>(
        builder: (context, logic, child) {
          return Scaffold(
            backgroundColor: Colors.yellow[200],
            appBar: AppBar(
              title: Text("Guess The Word - $playerName"),
              backgroundColor: Colors.blue,
              actions: [
                IconButton(
                  icon: Icon(Icons.scoreboard),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ScoreBoardScreen(scoreBoard: logic.scoreBoard),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Time Left: ${logic.timeLeft} s",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: logic.timeLeft > 5
                                ? Colors.green
                                : Colors.red)),
                    SizedBox(height: 10),
                    Text("Score: ${logic.score}",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    Text("Find the Word:",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900])),
                    SizedBox(height: 10),
                    Text(
                        logic.secretWord.isNotEmpty
                            ? "Word is ready!"
                            : "Loading...",
                        style: TextStyle(fontSize: 18, color: Colors.purple)),
                    SizedBox(height: 20),
                    TextField(
                        controller: logic.controller,
                        decoration: InputDecoration(
                            hintText: "Enter your guess",
                            hintStyle: TextStyle(color: Colors.blue[300]),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.white)),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () => logic.checkGuess(playerName, () {
                              showResult(context,
                                  "🎉 Correct! New word loaded!", Colors.green);
                            }),
                        child: Text("Submit Guess")),
                    SizedBox(height: 20),
                    Text(logic.hint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple)),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: logic.giveHint,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                        child: Text("Get Hint")),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void showResult(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: TextStyle(color: Colors.white)),
          backgroundColor: color),
    );
  }

  void _showGameOverDialog(BuildContext context, HomeLogic logic) {
    int finalScore = logic.score +
        logic.scoreBoard
            .fold<int>(0, (sum, item) => sum + (item['score'] as int));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Game Over"),
        content:
            Text("Your final score is $finalScore.\nDo you want to restart?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              logic.restartGame(context); // Restart the game using logic
            },
            child: Text("Restart"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Close the game screen
            },
            child: Text("Quit"),
          ),
        ],
      ),
    );
  }
}
