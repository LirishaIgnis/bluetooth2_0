import 'package:flutter/material.dart';
import '../../domain/entities/button_action_entity.dart';
import '../../domain/usecases/get_button_actions.dart';

class ButtonActionProvider extends ChangeNotifier {
  final GetButtonActions getButtonActions;

  List<ButtonActionEntity> _actions = [];
  List<ButtonActionEntity> get actions => _actions;

  ButtonActionProvider(this.getButtonActions);

  Future<void> loadActions() async {
    _actions = await getButtonActions.call();
    notifyListeners();
  }
}
