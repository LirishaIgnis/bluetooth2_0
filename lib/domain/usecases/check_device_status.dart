import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class CheckDeviceStatus {
  final FlutterBluetoothSerial bluetooth;

  CheckDeviceStatus(this.bluetooth);

  Future<Map<String, dynamic>> call(BluetoothDevice device) async {
    try {
      // Obtener dispositivos emparejados
      final bondedDevices = await bluetooth.getBondedDevices();
      final isBonded = bondedDevices.any((d) => d.address == device.address);

      return {
        "isBonded": isBonded,
        "isAccessible": isBonded, // Se asume accesibilidad si está emparejado
      };
    } catch (e) {
      return {
        "isBonded": false,
        "isAccessible": false,
        "error": e.toString(),
      };
    }
  }
}

