import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeLogic extends ChangeNotifier {
  int timeLeft = 30;
  int score = 100;
  late Timer _timer;
  String hint = "";
  String secretWord = "";
  bool isTimeUp = false;
  final TextEditingController controller = TextEditingController();
  final FocusNode inputFocus = FocusNode();
  List<Map<String, dynamic>> scoreBoard = [];

  void startTimer(VoidCallback onGameOver) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        timeLeft--;
      } else {
        _timer.cancel();
        isTimeUp = true;
        score = 0; // Ensure score is 0 if the user didn't find the word
        onGameOver();
      }
      notifyListeners();
    });
  }

  Future<void> fetchNewWord() async {
    final url = Uri.parse("https://random-word-api.herokuapp.com/word");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        secretWord = data.first;
        hint = "";
        score = 100;
        isTimeUp = false; // Reset time-up flag
      } else {
        secretWord = "error";
      }
    } catch (e) {
      secretWord = "error";
    }
    notifyListeners();
  }

  void checkGuess(String playerName, VoidCallback onCorrect) {
    if (isTimeUp) return; // Don't allow guesses if time is up

    String userGuess = controller.text.trim().toLowerCase();

    if (userGuess == secretWord) {
      scoreBoard
          .add({"word": secretWord, "score": score, "player": playerName});
      onCorrect();
      fetchNewWord().then((_) => startTimer(() => _showGameOverDialog));
    } else {
      score -= 10;
      if (score <= 0) {
        score = 0; // Prevent negative scores
        fetchNewWord();
      }
    }

    controller.clear();
    inputFocus.unfocus();
    notifyListeners();
  }

  void giveHint() {
    if (secretWord.isEmpty || isTimeUp) return;

    int wordLength = secretWord.length;
    List<int> hintIndexes = [];

    while (hintIndexes.length < 2) {
      int randomIndex = Random().nextInt(wordLength);
      if (!hintIndexes.contains(randomIndex)) {
        hintIndexes.add(randomIndex);
      }
    }

    String hintWord = "";
    for (int i = 0; i < wordLength; i++) {
      hintWord += hintIndexes.contains(i) ? "${secretWord[i]} " : "_ ";
    }

    hint = "Hint: Word has $wordLength letters\n$hintWord";
    score -= 5;
    notifyListeners();
  }

  void restartGame(BuildContext context) {
    score = 100;
    timeLeft = 30;
    scoreBoard.clear();
    isTimeUp = false;
    fetchNewWord().then((_) {
      startTimer(() => _showGameOverDialog(context));
    });
    notifyListeners();
  }

  void disposeResources() {
    _timer.cancel();
    controller.dispose();
    inputFocus.dispose();
  }

  void _showGameOverDialog(BuildContext context) {
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Game Over"),
          content: Text(
            isTimeUp
                ? "Time is up! Your score remains ${scoreBoard.fold<int>(0, (sum, item) => sum + (item['score'] as int))}. Do you want to restart?"
                : "Your final score is ${scoreBoard.fold<int>(0, (sum, item) => sum + (item['score'] as int))}. Do you want to restart?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                restartGame(context);
                Navigator.of(context).pop();
              },
              child: const Text("Restart"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("Quit"),
            ),
          ],
        ),
      );
    }
  }
} 