import '../../domain/entities/button_action.dart';

class ButtonActionModel extends ButtonAction {
  ButtonActionModel({
    required String id,
    required String name,
    required List<int> trama, // Cambiado a List<int>
  }) : super(id: id, name: name, trama: trama);

  factory ButtonActionModel.fromJson(Map<String, dynamic> json) {
    // Decodificar la trama desde una lista de números (si se almacena como tal)
    List<int> trama = List<int>.from(json['trama'] ?? []);

    return ButtonActionModel(
      id: json['id'], // Agregar 'id' si es necesario
      name: json['name'],
      trama: trama,
    );
  }

  Map<String, dynamic> toJson() {
    // Serializar la trama como una lista de números
    return {
      'id': id,
      'name': name,
      'trama': trama,
    };
  }
}

