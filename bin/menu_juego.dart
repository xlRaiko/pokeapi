import 'dart:io';
import 'usuario.dart';
import 'inventario.dart';
import 'tipoPokemon.dart';
import 'package:mysql1/mysql1.dart';
import 'menu_comandos.dart';

class MenuJuego {
  final MySqlConnection conn;
  final Usuario usuarioInstancia;

  MenuJuego({required this.conn, required this.usuarioInstancia});

  Future<void> mostrarMenu() async {
    var inventario = Inventario(conn: conn);

    stdout.writeln("Las rutas se han llenado de pokemons en tu ausencia, ¿listo para capturarlos a todos?");

    bool continuarEnJuego = true;

    while (continuarEnJuego) {
      stdout.writeln("\n😏 ¿Qué quieres hacer?");
      stdout.writeln("");
      stdout.writeln("1. 🐂 Ver mis pokemons");
      stdout.writeln("2. 💻 Abrir caja de pokemons");
      stdout.writeln("3. ⛺ Ver rutas disponibles");
      stdout.writeln("4. 🧮 Tipos del pokemon");
      stdout.writeln("5. 👋 Salir del juego");
      stdout.write("Elige una opción: ");
      String? opcion = stdin.readLineSync();

      if (opcion == null || opcion.trim().isEmpty) {
        stdout.writeln("⚠️ Entrada inválida. Por favor, ingresa una opción válida.");
        continue;
      }

      switch (opcion) {
        case '1':
          stdout.writeln("🐂 Mostrando tus pokemons...");
          await inventario.verInventario(usuarioInstancia.id);
          break;

        case '2':
          stdout.writeln("💻 Abriendo caja de almacenamiento...");
          await inventario.verCaja(usuarioInstancia.id);
          break;

        case '3':
          stdout.writeln("🌳Las rutas disponibles son:");
          await usuarioInstancia.mostrarRutasDisponibles();
          break;

        case '4':
          stdout.writeln("🧮¿De qué pokemon quieres saber su tipo?:");
          var tipoPokemon = TipoPokemon(conn: conn);
          await tipoPokemon.consultarTipoPokemon();
          break;

        case '5':
          stdout.writeln("👋 ¡Hasta pronto, ${usuarioInstancia.nombre}!");
          continuarEnJuego = false;
          break;

        case '6':
          stdout.writeln("\n🔹 Entrando al modo comandos...");
          var menuComandos = MenuComandos(conn: conn, usuarioId: usuarioInstancia.id);
          await menuComandos.mostrarComandos();
          break;

        default:
          stdout.writeln("⚠️ Opción inválida. Regresando al menú.");
          break;
      }
    }
  }
}