import '../../data/services/bluetooth_service.dart';

class EnableBluetooth {
  final BluetoothService bluetoothService;

  EnableBluetooth(this.bluetoothService);

  Future<void> call() async {
    await bluetoothService.enableBluetooth();
  }
}
