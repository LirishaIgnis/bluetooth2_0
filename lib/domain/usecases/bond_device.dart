import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../data/services/bluetooth_service.dart';

class BondDevice {
  final BluetoothService bluetoothService;

  BondDevice(this.bluetoothService);

  Future<void> call(BluetoothDevice device) async {
    await bluetoothService.bondDevice(device);
  }
}
