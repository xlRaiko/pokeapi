import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'pokemon.dart';
import 'mostrar_tipos.dart';
import 'mostrar_fortalezas.dart';

class TipoPokemon {
  final MySqlConnection conn;

  TipoPokemon({required this.conn});

  Future<void> consultarTipoPokemon() async {
    bool continuarConsultando = true;

    while (continuarConsultando) {
      stdout.write("¿De qué Pokémon quieres saber su tipo? (Ingresa el nombre): ");
      String? nombrePokemon = stdin.readLineSync();

      if (nombrePokemon == null || nombrePokemon.isEmpty) {
        stdout.writeln("⚠️ El nombre del Pokémon no puede estar vacío.");
        return;
      }

      // Obtener Pokémon desde la PokeAPI
      Pokemon? pokemon = await Pokemon.fromAPI(nombrePokemon.toLowerCase());
      if (pokemon == null) {
        stdout.writeln("⚠️ Pokémon no encontrado en la PokeAPI.");
      } else {
        await mostrarTipos(pokemon.tipos);
        await mostrarFortalezas(pokemon.tipos);
      }

      stdout.write("\n¿Quieres saber el tipo de otro Pokémon? (s/n): ");
      String? respuesta = stdin.readLineSync();

      if (respuesta == null || respuesta.toLowerCase() != 's') {
        continuarConsultando = false;
        stdout.writeln("🔙 Regresando al menú anterior...");
      }
    }
  }
}