import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  final FlutterBluetoothSerial bluetooth;

  BluetoothService(this.bluetooth);

  Future<bool> isBluetoothEnabled() async {
    return await bluetooth.isEnabled ?? false;
  }

  Future<void> enableBluetooth() async {
    if (!(await isBluetoothEnabled())) {
      await bluetooth.requestEnable();
    }
  }

  Future<bool> checkPermissions() async {
    PermissionStatus bluetoothPermission = await Permission.bluetooth.request();
    PermissionStatus locationPermission = await Permission.location.request();

    return bluetoothPermission.isGranted && locationPermission.isGranted;
  }

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await bluetooth.getBondedDevices();
  }

  Future<List<BluetoothDiscoveryResult>> discoverDevices() async {
    List<BluetoothDiscoveryResult> devices = [];
    await bluetooth.startDiscovery().listen((result) {
      if (!devices.any((element) => element.device.address == result.device.address)) {
        devices.add(result);
      }
    }).asFuture();
    return devices;
  }

  Future<void> bondDevice(BluetoothDevice device) async {
    bool? bonded = await bluetooth.bondDeviceAtAddress(device.address);
    if (bonded == true) { // Verificación explícita de true
      print("Dispositivo ${device.name} emparejado");
    } else {
      print("No se pudo emparejar el dispositivo ${device.name}");
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await BluetoothConnection.toAddress(device.address).then((connection) {
      print('Conectado a ${device.name}');
    }).catchError((error) {
      print('Error al conectar: $error');
    });
  }
}
