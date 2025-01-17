import '../../domain/entities/button_action.dart';

class ButtonActionRepository {
  final List<ButtonAction> _buttonActions = [
    ButtonAction(id: "1", name: "Puntos Local +", trama: "PL+"),
    ButtonAction(id: "2", name: "Puntos Local -", trama: "PL-"),
    ButtonAction(id: "3", name: "Faltas Local +", trama: "FL+"),
    ButtonAction(id: "4", name: "Faltas Local -", trama: "FL-"),
    ButtonAction(id: "5", name: "Puntos Visitante +", trama: "PV+"),
    ButtonAction(id: "6", name: "Puntos Visitante -", trama: "PV-"),
    ButtonAction(id: "7", name: "Faltas Visitante +", trama: "FV+"),
    ButtonAction(id: "8", name: "Faltas Visitante -", trama: "FV-"),
  ];

  List<ButtonAction> getAllButtonActions() => List.unmodifiable(_buttonActions);

  void updateTrama(String id, String newTrama) {
    final action = _buttonActions.firstWhere((action) => action.id == id);
    action.trama = newTrama;
  }
}

