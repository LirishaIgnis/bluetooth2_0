import '../data/repositories/repositories.dart';
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

  // Repositorios
  getIt.registerLazySingleton(() => ButtonActionRepository());

  // Casos de uso
  getIt.registerFactory(() => CheckPermissions(getIt<BluetoothService>()));
  getIt.registerFactory(() => EnableBluetooth(getIt<BluetoothService>()));
  getIt.registerFactory(() => DiscoverDevices(getIt<BluetoothService>()));
  getIt.registerFactory(() => BondDevice(getIt<BluetoothService>()));
  getIt.registerFactory(() => ConnectDevice(getIt<BluetoothService>()));
  getIt.registerFactory(() => BondDeviceWithControl(getIt<FlutterBluetoothSerial>()));
  getIt.registerLazySingleton(() => GetButtonActions(getIt<ButtonActionRepository>()));
  getIt.registerLazySingleton(() => UpdateButtonAction(getIt<ButtonActionRepository>()));

  // Proveedores
  getIt.registerLazySingleton(() => TimerProvider(
        getIt<DeviceConnectionProvider>(), // Agregado el parámetro requerido
      ));
  getIt.registerLazySingleton(() => ReceivedMessagesProvider());
  getIt.registerLazySingleton(() => MessageHistoryProvider());
  getIt.registerLazySingleton(() => DeviceConnectionProvider());
  getIt.registerLazySingleton(() => ButtonActionProvider(
        getIt<GetButtonActions>(),
        getIt<UpdateButtonAction>(),
      ));
}

