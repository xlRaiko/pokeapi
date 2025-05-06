import 'dart:io';
import 'comandos.dart';
import 'package:mysql1/mysql1.dart';

class MenuComandos {
  final MySqlConnection conn;
  final int usuarioId;

  MenuComandos({required this.conn, required this.usuarioId});

  Future<void> mostrarComandos() async {
    stdout.writeln("\n📜 **Lista de comandos disponibles:**");
    stdout.writeln("");
    stdout.writeln(":obtener [id] → Obtiene información del Pokémon con el ID especificado.");
    stdout.writeln(":verinventario → Muestra tu inventario de Pokémon.");
    stdout.writeln(":capturar [id] → Intenta capturar un Pokémon salvaje.");
    stdout.writeln(":liberar [id] → Libera un Pokémon de tu equipo.");
    stdout.writeln(":exp → Otorga experiencia al usuario.");
    stdout.writeln(":dexp → Retira experiencia al usuario.");
    stdout.writeln(":salir → Salir del modo comandos y regresar al menú.");

    stdout.writeln("\n🔹 Modo comandos activado. Escribe ':salir' para salir.");
    
    var comandos = Comandos(conn: conn, usuarioId: usuarioId);

    while (true) {
      stdout.write("\n🔹 Ingresa un comando (o ':salir' para volver al menú): ");
      String? input = stdin.readLineSync();

      if (input == null || input.trim().isEmpty) {
        stdout.writeln("⚠️ Entrada inválida. Usa ':' al inicio.");
        continue;
      }

      if (input.startsWith(":")) {
        if (input == ":salir") {
          stdout.writeln("🔙 Regresando al menú principal...");
          break;
        }
        try {
          await comandos.ejecutarComando(input);
        } catch (e) {
          stdout.writeln("⚠️ Error al ejecutar comando: $e");
        }
      } else {
        stdout.writeln("⚠️ Comando inválido. Usa ':' al inicio.");
      }
    }
  }
}