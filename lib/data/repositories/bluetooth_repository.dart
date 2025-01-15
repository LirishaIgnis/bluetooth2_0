import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

abstract class BluetoothRepository {
  Future<List<BluetoothDevice>> discoverDevices();
  Future<void> connectToDevice(BluetoothDevice device);
}

class BluetoothRepositoryImpl implements BluetoothRepository {
  final FlutterBluetoothSerial bluetooth;

  BluetoothRepositoryImpl(this.bluetooth);

  @override
  Future<List<BluetoothDevice>> discoverDevices() async {
    return await bluetooth.getBondedDevices();
  }

  @override
  Future<void> connectToDevice(BluetoothDevice device) async {
    await bluetooth.connect(device).then((connection) {
      // Aquí puedes manejar eventos de la conexión
    });
  }
}
