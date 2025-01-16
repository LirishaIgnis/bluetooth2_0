import 'package:flutter/material.dart';
import 'package:bluetooth2_0/injection/dependency_injection.dart';
import 'package:bluetooth2_0/presentation/routes/route_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura la inicialización de los bindings
  setupDependencies(); // Configura las dependencias
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter, // Configuración de rutas con GoRouter
      title: 'Bluetooth App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

