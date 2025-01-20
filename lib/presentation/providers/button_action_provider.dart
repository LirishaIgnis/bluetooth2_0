import 'package:flutter/material.dart';
import '../../domain/entities/button_action.dart';
import '../../domain/usecases/get_button_actions.dart';

class ButtonActionProvider with ChangeNotifier {
  final GetButtonActions getButtonActions;
  final UpdateButtonAction updateButtonAction;

  List<ButtonAction> _actions = [];

  ButtonActionProvider(this.getButtonActions, this.updateButtonAction) {
    _loadActions();
  }

  List<ButtonAction> get actions => _actions;

  /// Carga las acciones iniciales desde el caso de uso
  void _loadActions() {
    _actions = getButtonActions();
    for (var action in _actions) {
      print("Acción cargada: ID: ${action.id}, Nombre: ${action.name}, Trama: ${action.trama}");
    }
    notifyListeners();
  }

  /// Obtiene una acción específica por ID
  ButtonAction getActionById(String id) {
    return _actions.firstWhere(
      (action) => action.id == id,
      orElse: () => throw Exception("No se encontró una acción con el ID: $id"),
    );
  }

  /// Actualiza la trama de una acción específica
  void updateTrama(String id, List<int> newTrama) {
    updateButtonAction.call(id, newTrama);
    _loadActions();
  }

  /// Genera dinámicamente una nueva trama para los botones de puntaje
  List<int> generateDynamicTrama(String id, int puntosActuales) {
    final action = getActionById(id);

    // Convierte los puntos actuales a hexadecimal
    final puntosHex = puntosActuales.toRadixString(16).padLeft(2, '0').toUpperCase();

    // Modifica la trama reemplazando los valores dinámicos
    return action.trama.map((byte) {
      // Si el byte es dinámico (marcado como 0x95 en este caso), reemplázalo
      if (byte == 0x95) {
        return int.parse(puntosHex, radix: 16);
      }
      return byte;
    }).toList();
  }
}






