import 'package:flutter/material.dart';
import 'package:bluetooth2_0/injection/dependency_injection.dart';
import 'package:bluetooth2_0/presentation/routes/route_config.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:bluetooth2_0/presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura la inicialización de los bindings
  setupDependencies(); // Configura las dependencias
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GetIt.I<TimerProvider>()),
        ChangeNotifierProvider(create: (_) => GetIt.I<ButtonActionProvider>()),
        ChangeNotifierProvider(create: (_) => GetIt.I<MessageHistoryProvider>()),
        ChangeNotifierProvider(create: (_) => GetIt.I<DeviceConnectionProvider>()),
        ChangeNotifierProvider(create: (_) => GetIt.I<ReceivedMessagesProvider>()),
      ],
      child: MaterialApp.router(
        routerConfig: goRouter, // Configuración de rutas con GoRouter
        title: 'Bluetooth App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}

