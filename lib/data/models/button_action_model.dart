import '../../domain/entities/button_action_entity.dart';

class ButtonActionModel extends ButtonActionEntity {
  ButtonActionModel({required String name, required String trama})
      : super(name: name, trama: trama);

  factory ButtonActionModel.fromJson(Map<String, dynamic> json) {
    return ButtonActionModel(
      name: json['name'],
      trama: json['trama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'trama': trama,
    };
  }
}
