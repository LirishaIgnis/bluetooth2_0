import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class CommunicationPage extends StatefulWidget {
  final BluetoothDevice device;

  const CommunicationPage({Key? key, required this.device}) : super(key: key);

  @override
  _CommunicationPageState createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  final MessageHistoryProvider _messageHistoryProvider = GetIt.I<MessageHistoryProvider>();
  final DeviceConnectionProvider _connectionProvider = GetIt.I<DeviceConnectionProvider>();

  TextEditingController _messageController = TextEditingController();
  String _statusMessage = "Verificando dispositivo...";
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkDeviceStatus();
  }

  Future<void> _checkDeviceStatus() async {
    setState(() {
      _statusMessage = "Verificando dispositivo...";
      _isChecking = true;
    });

    // Simula la verificación de emparejamiento
    await Future.delayed(Duration(seconds: 2));

    if (widget.device.isBonded ?? false) {
      setState(() {
        _statusMessage = "Dispositivo listo para conectar.";
        _isChecking = false;
      });
    } else {
      setState(() {
        _statusMessage = "El dispositivo no está emparejado.";
        _isChecking = false;
      });
    }
  }

  Future<void> _connectToDevice() async {
    setState(() {
      _statusMessage = "Intentando conectar...";
    });

    bool connected = await _connectionProvider.connect(widget.device);
    if (connected) {
      setState(() {
        _statusMessage = "Conectado a ${widget.device.name}.";
      });
    } else {
      setState(() {
        _statusMessage = "No se pudo conectar al dispositivo.";
      });
    }
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty && _connectionProvider.isConnected) {
      _connectionProvider.connection?.output.add(Uint8List.fromList(message.codeUnits));
      _messageHistoryProvider.addMessage(message); // Guardar mensaje en el historial
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se puede enviar el mensaje: conexión no establecida o mensaje vacío.")),
      );
    }
  }

  @override
  void dispose() {
    _connectionProvider.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _messageHistoryProvider.messages;

    return Scaffold(
      appBar: AppBar(
        title: Text("Comunicación con ${widget.device.name}"),
        actions: [
          IconButton(
            onPressed: () {
              _connectionProvider.disconnect();
              GoRouter.of(context).go('/home');
            },
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _statusMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _isChecking ? null : _checkDeviceStatus,
                  child: Text(_isChecking ? "Verificando..." : "Verificar dispositivo"),
                ),
                ElevatedButton(
                  onPressed: _connectionProvider.isConnected || _isChecking
                      ? null
                      : _connectToDevice,
                  child: Text("Conectar"),
                ),
                if (_connectionProvider.isConnected)
                  ElevatedButton(
                    onPressed: () {
                      _connectionProvider.disconnect();
                      setState(() {
                        _statusMessage = "Desconectado.";
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("Desconectar"),
                  ),
              ],
            ),
            SizedBox(height: 20),
            if (_connectionProvider.isConnected) ...[
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: "Escribe un mensaje",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendMessage,
                child: Text("Enviar mensaje"),
              ),
            ],
            SizedBox(height: 20),
            Text(
              "Historial de mensajes:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

