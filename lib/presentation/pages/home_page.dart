import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
import '../../domain/usecases/usecases.dart';
import '../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dependencias inyectadas
  final CheckPermissions checkPermissions = GetIt.I<CheckPermissions>();
  final EnableBluetooth enableBluetooth = GetIt.I<EnableBluetooth>();
  final DiscoverDevices discoverDevices = GetIt.I<DiscoverDevices>();
  final BondDevice bondDevice = GetIt.I<BondDevice>();
  final ConnectDevice connectDevice = GetIt.I<ConnectDevice>();

  // Estado de la aplicación
  bool hasPermissions = false;
  bool isBluetoothEnabled = false;
  List<BluetoothDevice> bondedDevices = [];
  List<BluetoothDevice> discoveredDevices = [];
  bool isLoading = false;
  bool isConnected = false;
  Timer? _discoveryTimer;
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStream;

  @override
  void initState() {
    super.initState();
    checkInitialStates();
  }

  @override
  void dispose() {
    _discoveryStream?.cancel();
    _discoveryTimer?.cancel();
    super.dispose();
  }

  // Verificar permisos y estado del Bluetooth al iniciar la app
  Future<void> checkInitialStates() async {
    bool permissions = await checkPermissions();
    await enableBluetooth();

    setState(() {
      hasPermissions = permissions;
      isBluetoothEnabled = true;
    });
  }

  // Iniciar escaneo de dispositivos emparejados y no emparejados
  Future<void> scanDevices() async {
    setState(() {
      isLoading = true;
      bondedDevices.clear();
      discoveredDevices.clear();
    });

    try {
      bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();

      _discoveryStream = FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
        setState(() {
          if (!discoveredDevices.any((device) => device.address == result.device.address)) {
            discoveredDevices.add(result.device);
          }
        });
      });

      _discoveryTimer = Timer(Duration(seconds: 30), () {
        cancelDiscovery();
        print("Escaneo detenido automáticamente después de 30 segundos");
      });
    } catch (e) {
      print("Error durante el escaneo: $e");
    }
  }

  // Cancelar escaneo
  void cancelDiscovery() {
    _discoveryStream?.cancel();
    _discoveryTimer?.cancel();
    setState(() {
      isLoading = false;
    });
    print("Escaneo cancelado por el usuario");
  }

  // Emparejar un dispositivo y actualizar la lista de emparejados y confirmar comunicacion 
  Future<void> bondDeviceAndRefresh(BluetoothDevice device) async {
  await bondDevice(device);

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
          onPressed: () => Navigator.of(context).pop(), // Cerrar el diálogo
          child: Text("No"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar el diálogo
            Navigator.pushNamed(context, '/communication', arguments: device);
          },
          child: Text("Sí"),
        ),
      ],
    ),
  );
}

  // Conectar a un dispositivo
  Future<void> connectToDevice(BluetoothDevice device) async {
    await connectDevice(device);
    setState(() {
      isConnected = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Conectado a ${device.name}")),
    );
  }

  // Widget principal que construye la UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bluetooth Scanner")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusSection(),
            SizedBox(height: 20),
            _buildControlButtons(),
            SizedBox(height: 20),
            isLoading ? _buildLoadingIndicator() : _buildDeviceLists(),
          ],
        ),
      ),
    );
  }

  // Sección de estado de permisos y Bluetooth
  Widget _buildStatusSection() {
    return Column(
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
      ],
    );
  }

  // Botones de control (iniciar y cancelar búsqueda)
  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: (isLoading || !isBluetoothEnabled || !hasPermissions) ? null : scanDevices,
          child: Text(isLoading ? "Escaneando..." : "Iniciar búsqueda"),
        ),
        ElevatedButton(
          onPressed: isLoading ? cancelDiscovery : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: Text("Cancelar búsqueda"),
        ),
      ],
    );
  }

  // Indicador de carga mientras se realiza el escaneo
  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 10),
        Center(child: Text("Buscando dispositivos cercanos...")),
      ],
    );
  }

  // Listas de dispositivos emparejados y no emparejados
  Widget _buildDeviceLists() {
    return Expanded(
      child: Row(
        children: [
          // Lista de dispositivos emparejados
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dispositivos emparejados:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Divider(),
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
                              onTap: () => connectToDevice(device),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          // Lista de dispositivos no emparejados
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dispositivos no emparejados:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Divider(),
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
                              onTap: () => connectToDevice(device),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
