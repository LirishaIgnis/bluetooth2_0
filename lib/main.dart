import 'package:flutter/material.dart';
import 'package:bluetooth2_0/injection/dependency_injection.dart';
import 'package:bluetooth2_0/presentation/routes/route_config.dart';

void main() {
  setupDependencies();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'Bluetooth 2.0',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
