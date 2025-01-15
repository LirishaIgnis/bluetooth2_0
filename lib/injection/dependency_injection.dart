import 'package:get_it/get_it.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../data/services/bluetooth_service.dart';
import '../domain/usecases/check_permissions.dart';
import '../domain/usecases/enable_bluetooth.dart';
import '../domain/usecases/discover_devices.dart';
import '../domain/usecases/bond_device.dart';
import '../domain/usecases/connect_device.dart';

final locator = GetIt.instance;

void setupDependencies() {
  // Servicio Bluetooth
  locator.registerLazySingleton(() => BluetoothService(FlutterBluetoothSerial.instance));

  // Casos de uso
  locator.registerLazySingleton(() => CheckPermissions(locator()));
  locator.registerLazySingleton(() => EnableBluetooth(locator()));
  locator.registerLazySingleton(() => DiscoverDevices(locator()));
  locator.registerLazySingleton(() => BondDevice(locator()));
  locator.registerLazySingleton(() => ConnectDevice(locator()));
}

