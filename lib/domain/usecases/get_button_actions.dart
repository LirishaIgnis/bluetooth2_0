
import 'package:bluetooth2_0/data/repositories/repositories.dart';
import 'package:bluetooth2_0/domain/entities/button_action.dart';

class GetButtonActions {
  final ButtonActionRepository repository;

  GetButtonActions(this.repository);

  List<ButtonAction> call() => repository.getAllButtonActions();
}

class UpdateButtonAction {
  final ButtonActionRepository repository;

  UpdateButtonAction(this.repository);

  void call(String id, String newTrama) {
    repository.updateTrama(id, newTrama);
  }
}

