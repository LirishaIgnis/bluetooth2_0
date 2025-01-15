import '../../data/services/bluetooth_service.dart';

class CheckPermissions {
  final BluetoothService bluetoothService;

  CheckPermissions(this.bluetoothService);

  Future<bool> call() async {
    return await bluetoothService.checkPermissions();
  }
}
