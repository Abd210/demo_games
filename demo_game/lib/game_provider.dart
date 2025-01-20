import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GameProvider with ChangeNotifier {
  String _story =
      "You wake up in a vast desert. In front of you, there is a dark cave and a lush oasis. What will you do?";
  bool _isLoading = false;

  // Use the same URL as Postman for local testing
  final String apiUrl = "http://127.0.0.1:3000/game";
  final String clearUrl = "http://127.0.0.1:3000/clear";

  String get story => _story;
  bool get isLoading => _isLoading;

  Future<void> makeChoice(String choice) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'choice': choice}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _story = data['response'] ?? "Unexpected response from server.";
      } else {
        _story = "Failed to get response. Status: ${response.statusCode}";
      }
    } catch (error) {
      print("Error connecting to the server: $error");
      _story = "Error connecting to the server. Check your connection.";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearGame() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(clearUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _story = "Game reset. You are back at the beginning.";
      } else {
        _story = "Failed to reset the game.";
      }
    } catch (error) {
      print("Error connecting to the server: $error");
      _story = "Error connecting to the server.";
    }

    _isLoading = false;
    notifyListeners();
  }
}
