import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class CommunicationController {
  final BluetoothDevice device;
  BluetoothConnection? _connection;

  CommunicationController(this.device);

  // Conectar al dispositivo
  Future<bool> connect() async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
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
  }

  // Enviar mensaje
  void sendMessage(String message) {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(message.codeUnits));
      print("Mensaje enviado: $message");
    }
  }

  // Escuchar desconexión
  void listenForDisconnection(Function onDisconnected) {
    _connection?.input?.listen(null)?.onDone(() {
      onDisconnected();
    });
  }
}
