import 'package:bluetooth2_0/presentation/pages/tablero_prueba_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../pages/home_page.dart';
import '../pages/communication_page.dart';
import '../pages/tablero_page.dart';


final GoRouter goRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/communication',
      builder: (context, state) {
        final device = state.extra;
        if (device is BluetoothDevice) {
          return CommunicationPage(device: device);
        } else {
          return Scaffold(
            appBar: AppBar(title: Text("Error")),
            body: Center(
              child: Text("No se pudo encontrar el dispositivo."),
            ),
          );
        }
      },
    ),
    GoRoute(
      path: '/tablero',
      builder: (context, state) {
        final device = state.extra;
        if (device is BluetoothDevice) {
          return TableroPage(device: device);
        } else {
          return Scaffold(
            appBar: AppBar(title: Text("Error")),
            body: Center(
              child: Text("No se pudo encontrar el dispositivo."),
            ),
          );
        }
      },
    ),
    GoRoute(
      path: '/tableroPruebas',
      builder: (context, state) {
        final device = state.extra;
        if (device is BluetoothDevice) {
          return TableroPruebaPage(device: device);
        } else {
          return Scaffold(
            appBar: AppBar(title: Text("Error")),
            body: Center(
              child: Text("No se pudo encontrar el dispositivo."),
            ),
          );
        }
      },
    ),
  ],
);
