import 'package:flutter/material.dart';
import '../../domain/entities/button_action.dart';
import '../../domain/usecases/get_button_actions.dart';


class ButtonActionProvider with ChangeNotifier {
  final GetButtonActions getButtonActions;
  final UpdateButtonAction updateButtonAction;

  List<ButtonAction> _actions = [];

  ButtonActionProvider(this.getButtonActions, this.updateButtonAction) {
    _loadActions();
  }

  List<ButtonAction> get actions => _actions;

  void _loadActions() {
    _actions = getButtonActions();
    notifyListeners();
  }

  void updateTrama(String id, String newTrama) {
    updateButtonAction.call(id, newTrama);
    _loadActions();
  }
}




