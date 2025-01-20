import 'package:bluetooth2_0/data/repositories/button_action_repository.dart';

class UpdateButtonAction {
  final ButtonActionRepository repository;

  UpdateButtonAction(this.repository);

  /// Actualiza la trama de una acción específica
  void call(String id, List<int> newTrama) {
    repository.updateTrama(id, newTrama);
  }
}


