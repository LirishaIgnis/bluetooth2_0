import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BondDeviceWithControl {
  final FlutterBluetoothSerial bluetooth;

  BondDeviceWithControl(this.bluetooth);

  // Emparejar con control de tiempo y estado
  Future<bool> call(BluetoothDevice device, {int timeoutInSeconds = 15}) async {
    bool bondingCompleted = false;

    try {
      // Verificar si ya está emparejado
      final bondedDevices = await bluetooth.getBondedDevices();
      if (bondedDevices.any((d) => d.address == device.address)) {
        return true; // Ya está emparejado
      }

      // Establecer tiempo límite para el emparejamiento
      Future.delayed(Duration(seconds: timeoutInSeconds), () {
        if (!bondingCompleted) {
          throw Exception("Tiempo de emparejamiento agotado.");
        }
      });

      // Iniciar emparejamiento
      bondingCompleted = await bluetooth.bondDeviceAtAddress(device.address) ?? false;
      return bondingCompleted;
    } catch (e) {
      print("Error durante el emparejamiento: $e");
      rethrow; // Volver a lanzar la excepción para manejarla en la UI
    }
  }

  // Reiniciar Bluetooth
  Future<void> restartBluetooth() async {
    await bluetooth.requestDisable();
    await Future.delayed(Duration(seconds: 2));
    await bluetooth.requestEnable();
  }
}
