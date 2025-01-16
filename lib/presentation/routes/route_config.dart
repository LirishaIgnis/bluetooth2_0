import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/communication_page.dart';

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
  ],
);