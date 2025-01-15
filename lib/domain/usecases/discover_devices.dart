import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../data/services/bluetooth_service.dart';

class DiscoverDevices {
  final BluetoothService bluetoothService;

  DiscoverDevices(this.bluetoothService);

  Future<List<BluetoothDiscoveryResult>> call() async {
    return await bluetoothService.discoverDevices();
  }
}
