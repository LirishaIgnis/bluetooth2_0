import '../../domain/entities/button_action.dart';

class ButtonActionRepository {
  final List<ButtonAction> _buttonActions = [
    ButtonAction(
      id: "1",
      name: "Puntos Local +",
      trama: [0xAA, 0xAB, 0xAC, 0x03, 0x50, 0x68, 0x98, 0x05, 0x01, 0x34, 0x63, 0xAD],
    ),
    ButtonAction(
      id: "2",
      name: "Puntos Local -",
      trama: [0xAA, 0xAB, 0xAC, 0x03, 0x50, 0x68, 0x98, 0x05, 0x01, 0x34, 0x63, 0xAD],
    ),
    ButtonAction(
      id: "3",
      name: "Puntos Visitante +",
      trama: [0xAA, 0xAB, 0xAC, 0x02, 0xA5, 0x19, 0x96, 0x95, 0x10, 0x34, 0x23, 0xAD],
    ),
    ButtonAction(
      id: "4",
      name: "Puntos Visitante -",
      trama: [0xAA, 0xAB, 0xAC, 0x02, 0xA5, 0x19, 0x96, 0x95, 0x10, 0x34, 0x23, 0xAD],
    ),
    ButtonAction(
      id: "5",
      name: "Faltas Local +",
      trama: [0x46, 0x4C, 0x2B], // FL+ en ASCII
    ),
    ButtonAction(
      id: "6",
      name: "Faltas Local -",
      trama: [0x46, 0x4C, 0x2D], // FL- en ASCII
    ),
    ButtonAction(
      id: "7",
      name: "Faltas Visitante +",
      trama: [0x46, 0x56, 0x2B], // FV+ en ASCII
    ),
    ButtonAction(
      id: "8",
      name: "Faltas Visitante -",
      trama: [0x46, 0x56, 0x2D], // FV- en ASCII
    ),
  ];

  /// Retorna una lista inmutable de todas las acciones de botón
  List<ButtonAction> getAllButtonActions() => List.unmodifiable(_buttonActions);

  /// Retorna una acción específica por ID
  ButtonAction getActionById(String id) {
    return _buttonActions.firstWhere(
      (action) => action.id == id,
      orElse: () => throw Exception("No se encontró una acción con el ID: $id"),
    );
  }

  /// Actualiza la trama asociada con una acción de botón específica
  void updateTrama(String id, List<int> newTrama) {
    final action = getActionById(id);
    action.trama = newTrama;
  }

  /// Genera dinámicamente una nueva trama basada en el puntaje
 List<int> generateDynamicTrama(String id, int puntosActuales) {
  final action = getActionById(id);

  // Convierte los puntos actuales a hexadecimal
  final puntosHex = puntosActuales.toRadixString(16).padLeft(2, '0').toUpperCase();

  // Modifica la trama reemplazando los valores dinámicos
  return action.trama.map((byte) {
    if (byte == 0x95) {
      return int.parse(puntosHex, radix: 16); // Reemplazo dinámico
    }
    return byte;
  }).toList();
}
}


