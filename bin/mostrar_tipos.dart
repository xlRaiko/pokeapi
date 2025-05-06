import 'dart:io';

Future<void> mostrarTipos(List<String> tipos) async {
  if (tipos.isEmpty) {
    stdout.writeln("⚠️ Este Pokémon no tiene tipos definidos.");
    return;
  }

  stdout.writeln("\n📌 Tipos del Pokémon:");
  stdout.writeln();

  for (int i = 0; i < tipos.length; i++) {
    stdout.writeln("${i + 1}️⃣ Tipo ${i + 1}: ${tipos[i].capitalize()}");
  }
}

// Extensión para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}