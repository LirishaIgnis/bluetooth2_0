import 'package:flutter/material.dart';

class PermissionsWidget extends StatelessWidget {
  final bool hasPermissions;

  const PermissionsWidget({Key? key, required this.hasPermissions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          hasPermissions ? Icons.check_circle : Icons.error,
          color: hasPermissions ? Colors.green : Colors.red,
        ),
        SizedBox(width: 8),
        Text(hasPermissions ? "Permisos otorgados" : "Permisos denegados"),
      ],
    );
  }
}
