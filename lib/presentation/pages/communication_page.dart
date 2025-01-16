
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../domain/usecases/check_device_status.dart';
import '../../domain/usecases/connect_to_device.dart';

class CommunicationPage extends StatefulWidget {
  final BluetoothDevice device;

  const CommunicationPage({Key? key, required this.device}) : super(key: key);

  @override
  _CommunicationPageState createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  final CheckDeviceStatus checkDeviceStatus = GetIt.I<CheckDeviceStatus>();
  final ConnectToDevice connectToDevice = GetIt.I<ConnectToDevice>();

  BluetoothConnection? _connection;
  bool isConnected = false;
  bool isChecking = false;
  bool isConnecting = false;
  String statusMessage = "";

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  Future<void> _checkDevice() async {
    setState(() {
      isChecking = true;
      statusMessage = "Verificando dispositivo...";
    });

    try {
      final status = await checkDeviceStatus.call(widget.device);

      if (!status["isBonded"]) {
        setState(() {
          statusMessage = "El dispositivo no está emparejado. Dirección: ${widget.device.address}";
        });
        return;
      }

      setState(() {
        statusMessage = "El dispositivo está listo para conectar.";
      });
    } catch (e) {
      setState(() {
        statusMessage = "Error durante la verificación: $e";
      });
    } finally {
      setState(() {
        isChecking = false;
      });
    }
  }

  Future<void> _connectToDevice() async {
    setState(() {
      isConnecting = true;
      statusMessage = "Intentando conectar...";
    });

    try {
      _connection = await connectToDevice.call(widget.device);
      setState(() {
        isConnected = true;
        statusMessage = "Conectado a ${widget.device.name}.";
      });

      // Escuchar eventos de desconexión
      _connection?.input?.listen(null)?.onDone(() {
        setState(() {
          isConnected = false;
          statusMessage = "Conexión cerrada por el dispositivo.";
        });
      });
    } catch (e) {
      setState(() {
        statusMessage = "Error al conectar: ${e.toString()}";
      });
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  void _disconnect() async {
    await _connection?.close();
    setState(() {
      isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comunicación con ${widget.device.name}"),
        actions: [
          IconButton(
            onPressed: () {
              _disconnect();
              GoRouter.of(context).go('/home');
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              statusMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isChecking ? null : _checkDevice,
              child: Text(isChecking ? "Verificando..." : "Verificar Dispositivo"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnected || isConnecting
                  ? null
                  : _connectToDevice, // Intentar conectar
              child: Text(isConnecting ? "Conectando..." : "Conectar"),
            ),
          ],
        ),
      ),
    );
  }
}

