import '../../domain/entities/button_action.dart';

class ButtonActionModel extends ButtonAction {
  ButtonActionModel({required String id, required String name, required String trama})
      : super(id: id, name: name, trama: trama);

  factory ButtonActionModel.fromJson(Map<String, dynamic> json) {
    return ButtonActionModel(
      id: json['id'], // Agregar 'id' si es necesario
      name: json['name'],
      trama: json['trama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trama': trama,
    };
  }
}

