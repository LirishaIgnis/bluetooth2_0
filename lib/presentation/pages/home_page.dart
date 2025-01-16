import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/usecases.dart';
import '../../domain/usecases/bond_device_with_control.dart';
import '../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CheckPermissions checkPermissions = GetIt.I<CheckPermissions>();
  final EnableBluetooth enableBluetooth = GetIt.I<EnableBluetooth>();
  final DiscoverDevices discoverDevices = GetIt.I<DiscoverDevices>();
  final BondDeviceWithControl bondDeviceWithControl = GetIt.I<BondDeviceWithControl>();
  final ConnectDevice connectDevice = GetIt.I<ConnectDevice>();

  bool hasPermissions = false;
  bool isBluetoothEnabled = false;
  List<BluetoothDevice> bondedDevices = [];
  List<BluetoothDevice> discoveredDevices = [];
  bool isLoading = false;
  bool isConnected = false;
  bool isBonding = false;

  @override
  void initState() {
    super.initState();
    checkInitialStates();
  }

  Future<void> checkInitialStates() async {
    bool permissions = await checkPermissions();
    await enableBluetooth();

    setState(() {
      hasPermissions = permissions;
      isBluetoothEnabled = true;
    });
  }

  Future<void> scanDevices() async {
    setState(() {
      isLoading = true;
      bondedDevices.clear();
      discoveredDevices.clear();
    });

    try {
      bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();

      FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
        setState(() {
          if (!discoveredDevices.any((device) => device.address == result.device.address)) {
            discoveredDevices.add(result.device);
          }
        });
      }).onDone(() {
        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      print("Error durante el escaneo: $e");
    }
  }

  Future<void> bondDeviceAndRefresh(BluetoothDevice device) async {
    if (isBonding) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ya hay un proceso de emparejamiento en curso.")),
      );
      return;
    }

    isBonding = true;

    try {
      bool isBonded = await bondDeviceWithControl.call(device, timeoutInSeconds: 15);

      if (isBonded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Dispositivo emparejado exitosamente.")),
        );

        setState(() {
          bondedDevices.add(device);
        });

        // Mostrar diálogo de confirmación
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Emparejamiento exitoso"),
            content: Text("¿Deseas comunicarte con el dispositivo ${device.name}?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/communication', arguments: device);
                },
                child: Text("Sí"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error durante el emparejamiento: ${e.toString()}")),
      );
    } finally {
      isBonding = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bluetooth Scanner")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Estado de la Aplicación:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            PermissionsWidget(hasPermissions: hasPermissions),
            BluetoothStateWidget(
              isBluetoothEnabled: isBluetoothEnabled,
              onEnableBluetooth: enableBluetooth,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : scanDevices,
                  child: Text(isLoading ? "Buscando dispositivos..." : "Iniciar búsqueda"),
                ),
                ElevatedButton(
                  onPressed: isLoading ? FlutterBluetoothSerial.instance.cancelDiscovery : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Cancelar búsqueda"),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dispositivos emparejados:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: bondedDevices.isEmpty
                              ? Center(child: Text("No se encontraron dispositivos emparejados"))
                              : ListView.builder(
                                  itemCount: bondedDevices.length,
                                  itemBuilder: (context, index) {
                                    final device = bondedDevices[index];
                                    return ListTile(
                                      leading: Icon(Icons.bluetooth),
                                      title: Text(device.name ?? "Desconocido"),
                                      subtitle: Text(device.address),
                                      onTap: () => connectDevice(device),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dispositivos descubiertos:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: discoveredDevices.isEmpty
                              ? Center(child: Text("No se encontraron dispositivos"))
                              : ListView.builder(
                                  itemCount: discoveredDevices.length,
                                  itemBuilder: (context, index) {
                                    final device = discoveredDevices[index];
                                    return ListTile(
                                      leading: Icon(Icons.bluetooth_searching),
                                      title: Text(device.name ?? "Desconocido"),
                                      subtitle: Text(device.address),
                                      trailing: TextButton(
                                        onPressed: () => bondDeviceAndRefresh(device),
                                        child: Text("Emparejar"),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
