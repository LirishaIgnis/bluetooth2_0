import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../data/services/bluetooth_service.dart';

class ConnectDevice {
  final BluetoothService bluetoothService;

  ConnectDevice(this.bluetoothService);

  Future<void> call(BluetoothDevice device) async {
    await bluetoothService.connectToDevice(device);
  }
}
