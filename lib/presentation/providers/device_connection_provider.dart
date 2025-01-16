import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceConnectionProvider extends ChangeNotifier {
  BluetoothConnection? _connection;
  bool _isConnected = false;

  // Getter público para obtener la conexión actual
  BluetoothConnection? get connection => _connection;

  bool get isConnected => _isConnected;

  // Conectar al dispositivo
  Future<bool> connect(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _isConnected = true;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error al conectar: $e");
      return false;
    }
  }

  // Desconectar del dispositivo
  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
    _isConnected = false;
    notifyListeners();
  }

  // Escuchar desconexión
  void listenForDisconnection(Function onDisconnected) {
    _connection?.input?.listen(null)?.onDone(() {
      _isConnected = false;
      notifyListeners();
      onDisconnected();
    });
  }
}
