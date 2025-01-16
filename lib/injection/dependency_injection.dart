import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get_it/get_it.dart';
import '../data/services/bluetooth_service.dart';
import '../domain/usecases/bond_device_with_control.dart';
import '../domain/usecases/usecases.dart';
import '../presentation/providers/providers.dart';




final GetIt getIt = GetIt.instance;

void setupDependencies() {
  // Servicio Bluetooth
  getIt.registerSingleton<FlutterBluetoothSerial>(FlutterBluetoothSerial.instance);
  getIt.registerSingleton<BluetoothService>(BluetoothService(getIt<FlutterBluetoothSerial>()));

  // Casos de uso
  getIt.registerFactory(() => CheckPermissions(getIt<BluetoothService>()));
  getIt.registerFactory(() => EnableBluetooth(getIt<BluetoothService>()));
  getIt.registerFactory(() => DiscoverDevices(getIt<BluetoothService>()));
  getIt.registerFactory(() => BondDevice(getIt<BluetoothService>()));
  getIt.registerFactory(() => ConnectDevice(getIt<BluetoothService>()));
  getIt.registerFactory(() => BondDeviceWithControl(getIt<FlutterBluetoothSerial>())); // Nuevo

  // Otros registros...
  getIt.registerFactory(() => ConnectToDevice(getIt<FlutterBluetoothSerial>()));
  getIt.registerFactory(() => CheckDeviceStatus(getIt<FlutterBluetoothSerial>()));

   // Proveedores
  getIt.registerLazySingleton(() => MessageHistoryProvider());
  getIt.registerLazySingleton(() => DeviceConnectionProvider());

}

