class ButtonAction {
 final String id; // Identificador único del botón
  final String name; // Nombre del botón (visible en la UI)
  String trama; // Trama de comunicación asociada (editable)

  ButtonAction({required this.id, required this.name, required this.trama});
}