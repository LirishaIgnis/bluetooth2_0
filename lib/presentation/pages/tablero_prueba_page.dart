import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class TableroPruebaPage extends StatefulWidget {
  final BluetoothDevice device;

  const TableroPruebaPage({Key? key, required this.device}) : super(key: key);

  @override
  _TableroPruebaPageState createState() => _TableroPruebaPageState();
}

class _TableroPruebaPageState extends State<TableroPruebaPage> {
  final DeviceConnectionProvider _connectionProvider = GetIt.I<DeviceConnectionProvider>();
  final ButtonActionProvider _buttonActionProvider = GetIt.I<ButtonActionProvider>();
  final MessageHistoryProvider _messageHistoryProvider = GetIt.I<MessageHistoryProvider>();
  final TimerProvider _timerProvider = GetIt.I<TimerProvider>();

  String _statusMessage = "Verificando dispositivo...";
  bool _isChecking = true;

  // Estados locales del tablero
  int puntosLocal = 0;
  int puntosVisitante = 0;
  int periodo = 1;

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
    await Future.delayed(const Duration(seconds: 2));

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
    _timerProvider.stopTimer();
    setState(() {
      _statusMessage = "Desconectado.";
    });
  }

  void _showMessageHistory() {
    final messages = _messageHistoryProvider.messages.reversed.take(5).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Historial de mensajes'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index], style: const TextStyle(fontSize: 14)),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _connectionProvider.disconnect();
    _timerProvider.stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Control Tablero Deportivo', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: _disconnectFromDevice,
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              GoRouter.of(context).push('/communication', extra: widget.device);
            },
            icon: const Icon(Icons.arrow_back),
            tooltip: "Volver a comunicación",
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Mensajes de estado
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Controles de conexión Bluetooth
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
                    child: const Text("Conectar"),
                  ),
                  if (_connectionProvider.isConnected)
                    ElevatedButton(
                      onPressed: _disconnectFromDevice,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Desconectar"),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Temporizador y botones de control
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatTime(_timerProvider.remainingSeconds),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade300),
                          onPressed: _timerProvider.startTimer,
                          child: const Text('Iniciar'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade300),
                          onPressed: _timerProvider.pauseTimer,
                          child: const Text('Pausar'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade300),
                          onPressed: _timerProvider.resetTimer,
                          child: const Text('Reiniciar'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Marcador de puntos y faltas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  marcadorEquipo('LOCAL', puntosLocal, true),
                  Text('Periodo $periodo', style: const TextStyle(color: Colors.white, fontSize: 24)),
                  marcadorEquipo('VISITANTE', puntosVisitante, false),
                ],
              ),
              const SizedBox(height: 20),

              // Controles de puntos
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        controlBotones('Puntos Local', 'PL+', () => setState(() => puntosLocal++)),
                        controlBotones('Puntos Visitante', 'PV+', () => setState(() => puntosVisitante++)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () => setState(() => periodo++),
                      child: const Text('Cambiar Periodo'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'history',
            backgroundColor: Colors.blue,
            onPressed: _showMessageHistory,
            child: const Icon(Icons.history),
            tooltip: "Ver historial de mensajes",
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'toCommunication',
            backgroundColor: Colors.orange,
            onPressed: () {
              GoRouter.of(context).push('/communication', extra: widget.device);
            },
            child: const Icon(Icons.arrow_back),
            tooltip: "Volver a comunicación",
          ),
        ],
      ),
    );
  }

  Widget marcadorEquipo(String titulo, int puntos, bool esLocal) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 18)),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: esLocal ? Colors.blue[900] : Colors.red[900],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            puntos.toString(),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget controlBotones(String titulo, String trama, VoidCallback onSumar) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade200),
          onPressed: () {
            onSumar();
            _timerProvider.sendInterruptTrama(
              _buttonActionProvider.actions.firstWhere((action) => action.trama == trama),
            );
          },
          child: Text(titulo),
        ),
      ],
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
