import 'dart:async';
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
            icon: Icon(Icons.home),
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

              // Marcador de puntos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  marcadorEquipo('LOCAL', puntosLocal, faltasLocal, true),
                  Text('Periodo $periodo', style: const TextStyle(color: Colors.white, fontSize: 24)),
                  marcadorEquipo('VISITANTE', puntosVisitante, faltasVisitante, false),
                ],
              ),
              const SizedBox(height: 20),

              // Controles de puntos y faltas
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
                        controlBotones('Puntos Local', () => setState(() => puntosLocal++), () {
                          if (puntosLocal > 0) setState(() => puntosLocal--);
                        }),
                        controlBotones('Puntos Visitante', () => setState(() => puntosVisitante++), () {
                          if (puntosVisitante > 0) setState(() => puntosVisitante--);
                        }),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        controlBotones('Faltas Local', () => setState(() => faltasLocal++),
                            () => setState(() => faltasLocal--)),
                        controlBotones('Faltas Visitante', () => setState(() => faltasVisitante++),
                            () => setState(() => faltasVisitante--)),
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

  Widget controlBotones(String titulo, VoidCallback onSumar, VoidCallback onRestar) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 16)),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade200),
              onPressed: onSumar,
              child: const Text('+'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade200),
              onPressed: onRestar,
              child: const Text('-'),
            ),
          ],
        ),
      ],
    );
  }
}


