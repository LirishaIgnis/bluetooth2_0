import '../entities/button_action_entity.dart';
import '../../data/repositories/button_action_repository.dart';

class GetButtonActions {
  final ButtonActionRepository repository;

  GetButtonActions(this.repository);

  Future<List<ButtonActionEntity>> call() {
    return repository.getButtonActions();
  }
}
