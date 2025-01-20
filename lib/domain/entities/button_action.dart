class ButtonAction {
  final String id;
  final String name;
  List<int> trama; // Cambiado a List<int>

  ButtonAction({
    required this.id,
    required this.name,
    required this.trama,
  });

  /// Convierte la trama a una representación hexadecimal en cadena
  String get tramaAsHex {
    return trama.map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
  }
}
