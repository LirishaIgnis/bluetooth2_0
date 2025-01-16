import '../models/button_action_model.dart';

class ButtonActionRepository {
  Future<List<ButtonActionModel>> getButtonActions() async {
    // Datos simulados
    return [
      ButtonActionModel(name: "Encender", trama: "ON"),
      ButtonActionModel(name: "Apagar", trama: "OFF"),
      ButtonActionModel(name: "Reiniciar", trama: "RESET"),
    ];
  }
}
