import 'package:bluetooth2_0/data/repositories/repositories.dart';
import 'package:bluetooth2_0/domain/entities/button_action.dart';

class GetButtonActions {
  final ButtonActionRepository repository;

  GetButtonActions(this.repository);

  /// Obtiene todas las acciones de botones desde el repositorio
  List<ButtonAction> call() => repository.getAllButtonActions();
}

class UpdateButtonAction {
  final ButtonActionRepository repository;

  UpdateButtonAction(this.repository);

  /// Actualiza la trama asociada con una acción específica
  void call(String id, List<int> newTrama) {
    repository.updateTrama(id, newTrama);
  }
}

