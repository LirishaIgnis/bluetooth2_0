import 'dart:async';
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
  final ReceivedMessagesProvider _receivedMessagesProvider = GetIt.I<ReceivedMessagesProvider>();
  final DeviceConnectionProvider _connectionProvider = GetIt.I<DeviceConnectionProvider>();

  TextEditingController _messageController = TextEditingController();
  String _statusMessage = "Verificando dispositivo...";
  bool _isChecking = true;
  StreamSubscription<String>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _checkDeviceStatus();
    _startReceivingMessages();
  }

  Future<void> _checkDeviceStatus() async {
    setState(() {
      _statusMessage = "Verificando dispositivo...";
      _isChecking = true;
    });

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

  void _disconnectFromDevice() {
    _connectionProvider.disconnect();
    _messageSubscription?.cancel();
    setState(() {
      _statusMessage = "Desconectado.";
    });
  }

  void _startReceivingMessages() {
    final connection = _connectionProvider.connection;

    if (connection != null && connection.input != null) {
      _messageSubscription = connection.input!.listen(
        (data) {
          final message = String.fromCharCodes(data);
          print("Datos en crudo recibidos: $data");
          print("Convertido a texto: $message");
          _receivedMessagesProvider.addMessage(message);
          setState(() {});
        },
        onError: (error) {
          print("Error al recibir datos: $error");
        },
      ) as StreamSubscription<String>?;
    }
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty && _connectionProvider.isConnected) {
      _connectionProvider.connection?.output.add(Uint8List.fromList(message.codeUnits));
      _messageHistoryProvider.addMessage(message);
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
    _messageSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _messageHistoryProvider.messages;
    final receivedMessages = _receivedMessagesProvider.messages;

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
                    onPressed: _disconnectFromDevice,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("Desconectar"),
                  ),
              ],
            ),
            SizedBox(height: 20),
            if (_connectionProvider.isConnected) ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListView.builder(
                    itemCount: receivedMessages.length,
                    itemBuilder: (context, index) {
                      return Text(
                        receivedMessages[index],
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'toTablero',
            onPressed: () {
              GoRouter.of(context).go('/tablero', extra: widget.device);
            },
            child: Icon(Icons.dashboard),
            tooltip: "Ir al Tablero",
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'toTableroPruebas',
            onPressed: () {
              GoRouter.of(context).go('/tableroPruebas', extra: widget.device);
            },
            child: Icon(Icons.auto_graph),
            tooltip: "Ir al Tablero de Pruebas",
          ),
        ],
      ),
    );
  }
}
