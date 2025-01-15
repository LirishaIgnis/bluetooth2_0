import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class CommunicationPage extends StatefulWidget {
  final BluetoothDevice device;

  const CommunicationPage({Key? key, required this.device}) : super(key: key);

  @override
  _CommunicationPageState createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  late TextEditingController _messageController;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    // Aquí puedes inicializar la conexión con el dispositivo si es necesario
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    String message = _messageController.text;
    if (message.isNotEmpty) {
      // Lógica para enviar el mensaje al dispositivo Bluetooth
      print("Enviando mensaje: $message");
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Comunicación con ${widget.device.name}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "Comunicación con el dispositivo ${widget.device.name}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: "Escribe un mensaje",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text("Enviar"),
            ),
          ],
        ),
      ),
    );
  }
}
