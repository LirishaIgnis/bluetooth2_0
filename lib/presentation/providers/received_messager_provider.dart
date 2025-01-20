import 'package:flutter/material.dart';

class ReceivedMessagesProvider extends ChangeNotifier {
  final List<String> _messages = [];

  List<String> get messages => List.unmodifiable(_messages);

  void addMessage(String message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
