import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GameProvider extends ChangeNotifier {
  // Our combined story
  String _story = 'Welcome to the Survival Adventure! Make your first choice.';
  bool _isLoading = false;

  // Adjust these to match your Node server setup
  final String _baseUrl = 'http://localhost:3000'; // server URL
  final String _devKey = 'YOUR_SECRET_KEY';       // Must match SECRET_KEY in Node

  String get story => _story;
  bool get isLoading => _isLoading;

  /// Submit a choice to /game
  Future<void> makeChoice(String choice) async {
    _isLoading = true;
    notifyListeners();

    // Show the user's choice in the local story
    _story += '\nYou: $choice\n';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/game'),
        headers: {
          'Content-Type': 'application/json',
          'devKey': _devKey,
        },
        body: json.encode({'choice': choice}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final serverResponse = data['response'] as String;
        // Append AI response
        _story += '$serverResponse\n';
      } else {
        _story += '\n[Server Error: ${response.statusCode}]\n';
      }
    } catch (e) {
      _story += '\n[Network/Parsing error: $e]\n';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear the game by calling /clear
  Future<void> clearGame() async {
    _isLoading = true;
    notifyListeners();

    _story = 'Clearing game...\n';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/clear'),
        headers: {
          'devKey': _devKey,
        },
      );

      if (response.statusCode == 200) {
        _story = 'Game has been reset. Start again.\n';
      } else {
        _story =
            '\n[Server Error clearing: ${response.statusCode}]\n';
      }
    } catch (e) {
      _story += '\n[Error clearing: $e]\n';
    }

    _isLoading = false;
    notifyListeners();
  }
}
