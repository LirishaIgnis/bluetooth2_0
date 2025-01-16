import 'dart:typed_data';
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
  TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    // Cerrar conexión Bluetooth y limpiar listeners
    _disconnect();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _checkDevice() async {
    setState(() {
      isChecking = true;
      statusMessage = "Verificando dispositivo...";
    });

    try {
      final status = await checkDeviceStatus.call(widget.device);

      if (!mounted) return;

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
      if (mounted) {
        setState(() {
          statusMessage = "Error durante la verificación: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isChecking = false;
        });
      }
    }
  }

  Future<void> _connectToDevice() async {
    setState(() {
      isConnecting = true;
      statusMessage = "Intentando conectar...";
    });

    try {
      _connection = await connectToDevice.call(widget.device);

      if (!mounted) return;

      setState(() {
        isConnected = true;
        statusMessage = "Conectado a ${widget.device.name}.";
      });

      // Escuchar eventos de desconexión
      _connection?.input?.listen((data) {
        print("Datos recibidos: $data");
      })?.onDone(() {
        if (mounted) {
          setState(() {
            isConnected = false;
            statusMessage = "Conexión cerrada por el dispositivo.";
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          statusMessage = "Error al conectar: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isConnecting = false;
        });
      }
    }
  }

  Future<void> _disconnect() async {
    await _connection?.close();
    _connection = null;
    if (mounted) {
      setState(() {
        isConnected = false;
        statusMessage = "Desconectado.";
      });
    }
  }

  void _goBackHome() {
    _disconnect();
    GoRouter.of(context).go('/home');
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty && isConnected) {
      _connection?.output.add(Uint8List.fromList(message.codeUnits));
      _messageController.clear();
      print("Mensaje enviado: $message");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se puede enviar el mensaje: conexión no establecida o mensaje vacío.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comunicación con ${widget.device.name}"),
        actions: [
          IconButton(
            onPressed: _goBackHome,
            icon: Icon(Icons.home),
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
            if (!isConnected)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: isChecking ? null : _checkDevice,
                    icon: Icon(Icons.search),
                    label: Text(isChecking ? "Verificando..." : "Verificar Dispositivo"),
                  ),
                  ElevatedButton.icon(
                    onPressed: isConnected || isConnecting ? null : _connectToDevice,
                    icon: isConnecting
                        ? CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        : Icon(Icons.bluetooth),
                    label: Text(isConnecting ? "Conectando..." : "Conectar"),
                  ),
                ],
              ),
            if (isConnected) ...[
              SizedBox(height: 20),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: "Escribe un mensaje",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _sendMessage,
                icon: Icon(Icons.send),
                label: Text("Enviar mensaje"),
              ),
              Spacer(),
              ElevatedButton.icon(
                onPressed: _goBackHome,
                icon: Icon(Icons.home),
                label: Text("Volver al Home"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
