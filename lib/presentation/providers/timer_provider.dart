import 'dart:async';
import 'dart:typed_data';
import 'package:bluetooth2_0/domain/entities/button_action.dart';
import 'package:flutter/material.dart';
import '../providers/device_connection_provider.dart';

class TimerProvider with ChangeNotifier {
  final DeviceConnectionProvider connectionProvider;
  int _remainingSeconds;

  TimerProvider(this.connectionProvider, [this._remainingSeconds = 180]); // Tiempo inicial configurable

  Timer? _timer;
  bool _isRunning = false;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  void startTimer() {
  if (_isRunning) return;

  _isRunning = true;
  _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
    if (_remainingSeconds > 0) {
      _remainingSeconds--;
      _sendTramaForTime(); // Enviar trama
      notifyListeners(); // Notificar cambios
    } else {
      _sendFinalTimeTrama(); // Enviar trama de tiempo final
      stopTimer(); // Detener temporizador
    }
  });
  notifyListeners();
}


  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    pauseTimer();
    _remainingSeconds = 180; // Reinicia a 3 minutos por defecto
    _sendTramaForTime(); // Opcional: enviar el estado inicial
    notifyListeners();
  }

  void stopTimer({VoidCallback? onStop}) {
    _timer?.cancel();
    _isRunning = false;
    onStop?.call();
    notifyListeners();
  }

  void _sendTramaForTime() {
    if (!connectionProvider.isConnected) {
      print("Dispositivo no conectado. No se puede enviar la trama.");
      return;
    }

    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    // Construye la trama de tiempo
    final List<int> trama = [
      0xAA, 0xAB, 0xAC, 0x00,
      minutes, seconds,
      0x98, 0x98, 0x11, 0x32, 0x62, 0xAD
    ];

    // Convierte a Uint8List y envía
    final Uint8List tramaUint8 = Uint8List.fromList(trama);
    connectionProvider.connection?.output.add(tramaUint8);
    _logTrama(tramaUint8);
  }

  void _sendFinalTimeTrama() {
    if (!connectionProvider.isConnected) {
      print("Dispositivo no conectado. No se puede enviar la trama final.");
      return;
    }

    final List<int> tramaFinal = [
      0xAA, 0xAB, 0xAC, 0x00,
      0x00, 0x00, // Minutos y segundos en 0
      0x98, 0x98, 0x11, 0x32, 0x62, 0xAD
    ];

    final Uint8List tramaUint8 = Uint8List.fromList(tramaFinal);
    connectionProvider.connection?.output.add(tramaUint8);
    _logTrama(tramaUint8);
  }

  void sendInterruptTrama(ButtonAction action) {
    if (!connectionProvider.isConnected) {
      print("Dispositivo no conectado. No se puede enviar la trama de interrupción.");
      return;
    }

    final Uint8List trama = Uint8List.fromList(action.trama.codeUnits);
    connectionProvider.connection?.output.add(trama);
    _logTrama(trama);
  }

  void _logTrama(Uint8List trama) {
    print("Trama enviada: ${trama.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}");
  }
}

