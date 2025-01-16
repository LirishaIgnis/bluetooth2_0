
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:bluetooth2_0/presentation/state/communication_controller.dart';
import 'package:go_router/go_router.dart';

class CommunicationPage extends StatefulWidget {
  final BluetoothDevice device;

  const CommunicationPage({Key? key, required this.device}) : super(key: key);

  @override
  _CommunicationPageState createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  late CommunicationController _controller;
  late TextEditingController _messageController;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _controller = CommunicationController(widget.device);
    _messageController = TextEditingController();
    _connectToDevice();
  }

  @override
  void dispose() {
    _controller.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _connectToDevice() async {
    bool success = await _controller.connect();
    setState(() {
      isConnected = success;
    });

    if (success) {
      _controller.listenForDisconnection(() {
        setState(() {
          isConnected = false;
        });
        _showDisconnectedAlert();
      });
    } else {
      _showConnectionErrorAlert();
    }
  }

  void _showDisconnectedAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Desconexión"),
        content: Text("El dispositivo ${widget.device.name} se ha desconectado."),
        actions: [
          TextButton(
            onPressed: () {
              context.go('/home');
            },
            child: Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void _showConnectionErrorAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error de conexión"),
        content: Text("No se pudo conectar al dispositivo ${widget.device.name}."),
        actions: [
          TextButton(
            onPressed: () {
              context.go('/home');
            },
            child: Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String message = _messageController.text;
    if (message.isNotEmpty && isConnected) {
      _controller.sendMessage(message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comunicación con ${widget.device.name}"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _controller.disconnect();
              context.go('/home');
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      size: 80,
                      color: isConnected ? Colors.blue : Colors.red,
                    ),
                    SizedBox(height: 10),
                    Text(
                      isConnected
                          ? "Conectado a ${widget.device.name}"
                          : "Desconectado de ${widget.device.name}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: "Escribe un mensaje",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.send),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isConnected ? _sendMessage : null,
              icon: Icon(Icons.send),
              label: Text("Enviar Mensaje"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _controller.disconnect();
                context.go('/home');
              },
              icon: Icon(Icons.logout),
              label: Text("Desconectar y Volver a Home"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
