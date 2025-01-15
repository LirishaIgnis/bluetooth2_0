import 'package:flutter/material.dart';

class BluetoothStateWidget extends StatelessWidget {
  final bool isBluetoothEnabled;
  final VoidCallback onEnableBluetooth;

  const BluetoothStateWidget({
    Key? key,
    required this.isBluetoothEnabled,
    required this.onEnableBluetooth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isBluetoothEnabled ? Icons.bluetooth : Icons.bluetooth_disabled,
          color: isBluetoothEnabled ? Colors.green : Colors.red,
        ),
        SizedBox(width: 8),
        Text(isBluetoothEnabled ? "Bluetooth encendido" : "Bluetooth apagado"),
        if (!isBluetoothEnabled)
          TextButton(
            onPressed: onEnableBluetooth,
            child: Text("Encender"),
          ),
      ],
    );
  }
}
