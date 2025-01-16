import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ConnectToDevice {
  final FlutterBluetoothSerial bluetooth;

  ConnectToDevice(this.bluetooth);

  Future<BluetoothConnection> call(BluetoothDevice device) async {
    try {
      print("Intentando conectar a ${device.name} (${device.address})");

      // Intentar conectar con timeout
      final connection = await BluetoothConnection.toAddress(device.address)
          .timeout(Duration(seconds: 15), onTimeout: () {
        throw TimeoutException("Tiempo de conexión agotado.");
      });

      print("Conexión establecida con ${device.name}");
      return connection;
    } catch (e) {
      print("Error al conectar con ${device.name}: $e");
      rethrow; // Relanzar el error para manejarlo en la UI
    }
  }
}

