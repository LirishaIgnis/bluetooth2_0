import 'package:flutter/material.dart';

class MessageHistoryProvider extends ChangeNotifier {
  final List<String> _messages = [];

  // Obtener los últimos 5 mensajes
  List<String> get messages => List.unmodifiable(_messages);

  // Agregar un mensaje al historial
  void addMessage(String message) {
    if (_messages.length == 5) {
      _messages.removeAt(0); // Elimina el mensaje más antiguo
    }
    _messages.add(message);
    notifyListeners();
  }
}
