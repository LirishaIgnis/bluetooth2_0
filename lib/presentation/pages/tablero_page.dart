import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class TableroPage extends StatefulWidget {
  final BluetoothDevice device;

  const TableroPage({Key? key, required this.device}) : super(key: key);

  @override
  _TableroPageState createState() => _TableroPageState();
}

class _TableroPageState extends State<TableroPage> {
  final DeviceConnectionProvider _connectionProvider = GetIt.I<DeviceConnectionProvider>();
  final ButtonActionProvider _buttonActionProvider = GetIt.I<ButtonActionProvider>();
  final MessageHistoryProvider _messageHistoryProvider = GetIt.I<MessageHistoryProvider>();

  String _statusMessage = "Verificando dispositivo...";
  bool _isChecking = true;

  // Estados locales del tablero
  int puntosLocal = 0;
  int puntosVisitante = 0;
  int faltasLocal = 0;
  int faltasVisitante = 0;
  int periodo = 1;

  Timer? _timer;
  int segundos = 0;
  bool enEjecucion = false;

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

  void _disconnectFromDevice() {
    _connectionProvider.disconnect();
    setState(() {
      _statusMessage = "Desconectado.";
    });
  }

  // Métodos del temporizador
  void iniciarTimer() {
    if (enEjecucion) return;
    enEjecucion = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          segundos++;
        });
      }
    });
  }

  void pausarTimer() {
    _timer?.cancel();
    enEjecucion = false;
  }

  void reiniciarTimer() {
    pausarTimer();
    setState(() {
      segundos = 0;
    });
  }

  void cambiarPeriodo() {
    setState(() {
      periodo++;
      reiniciarTimer();
    });
  }

  String formatearTiempo(int segundosTotales) {
    final minutos = segundosTotales ~/ 60;
    final segundos = segundosTotales % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  void _sendTrama(String trama) {
    if (_connectionProvider.isConnected) {
      _connectionProvider.connection?.output.add(Uint8List.fromList(trama.codeUnits));
      _messageHistoryProvider.addMessage(trama);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Trama enviada: $trama")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No hay conexión activa")),
      );
    }
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
    _timer?.cancel();
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
            onPressed: () {
              _connectionProvider.disconnect();
              GoRouter.of(context).go('/home');
            },
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

              // Temporizador
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Text(
                      formatearTiempo(segundos),
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
                          onPressed: iniciarTimer,
                          child: const Text('Iniciar'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade300),
                          onPressed: pausarTimer,
                          child: const Text('Pausar'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade300),
                          onPressed: reiniciarTimer,
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
                  marcadorEquipo('LOCAL', puntosLocal, faltasLocal, true),
                  Text('Periodo $periodo', style: const TextStyle(color: Colors.white, fontSize: 24)),
                  marcadorEquipo('VISITANTE', puntosVisitante, faltasVisitante, false),
                ],
              ),
              const SizedBox(height: 20),

              // Controles de puntos y faltas con envío de tramas
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
                        controlBotones('Puntos Local', 'PL+', () => setState(() => puntosLocal++),
                            () => setState(() => puntosLocal > 0 ? puntosLocal-- : 0)),
                        controlBotones('Puntos Visitante', 'PV+', () => setState(() => puntosVisitante++),
                            () => setState(() => puntosVisitante > 0 ? puntosVisitante-- : 0)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        controlBotones('Faltas Local', 'FL+', () => setState(() => faltasLocal++),
                            () => setState(() => faltasLocal > 0 ? faltasLocal-- : 0)),
                        controlBotones('Faltas Visitante', 'FV+', () => setState(() => faltasVisitante++),
                            () => setState(() => faltasVisitante > 0 ? faltasVisitante-- : 0)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: cambiarPeriodo,
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

  Widget marcadorEquipo(String titulo, int puntos, int faltas, bool esLocal) {
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
        const SizedBox(height: 8),
        Text('Faltas: $faltas', style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }

  Widget controlBotones(String titulo, String trama, VoidCallback onSumar, VoidCallback onRestar) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 16)),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade200),
              onPressed: () {
                onSumar();
                _sendTrama(trama);
              },
              child: const Text('+'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade200),
              onPressed: () {
                onRestar();
                _sendTrama("-$trama");
              },
              child: const Text('-'),
            ),
          ],
        ),
      ],
    );
  }
}

