import 'package:bluetooth2_0/data/repositories/button_action_repository.dart';


class UpdateButtonAction {
  final ButtonActionRepository repository;

  UpdateButtonAction(this.repository);

  void call(String id, String newTrama) {
    repository.updateTrama(id, newTrama);
  }
}

