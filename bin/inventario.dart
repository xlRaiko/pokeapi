import 'package:mysql1/mysql1.dart';
import 'pokemon.dart';
import 'dart:io';

class Inventario {
  final MySqlConnection conn;

  Inventario({required this.conn});

  // Mostrar Pokémon en el inventario
  Future<void> verInventario(int usuarioId) async {
    var results = await conn.query(
      'SELECT pokemon_id FROM inventario_pokemons WHERE usuario_id = ?',
      [usuarioId]
    );

    if (results.isEmpty) {
      stdout.writeln("⚠️ No tienes Pokémon en tu inventario.");
      return;
    }

    stdout.writeln("🐉 Tus Pokémon en el inventario:");
    for (var row in results) {
      int pokemonId = row['pokemon_id'];
      Pokemon? pokemon = await Pokemon.fromAPI(pokemonId.toString());
      if (pokemon != null) {
        stdout.writeln("- ID: ${pokemon.id} // Nombre: ${pokemon.nombre}");
      } else {
        stdout.writeln("- ID: $pokemonId // Nombre: Desconocido (no se pudo cargar)");
      }
    }
  }

  // Mostrar Pokémon en la caja de almacenamiento
  Future<void> verCaja(int usuarioId) async {
    var results = await conn.query(
      'SELECT pokemon_id FROM caja_pokemons WHERE usuario_id = ?',
      [usuarioId]
    );

    if (results.isEmpty) {
      stdout.writeln("⚠️ No tienes Pokémon en tu caja de almacenamiento.");
      return;
    }

    stdout.writeln("📦 Tus Pokémon en la caja:");
    for (var row in results) {
      int pokemonId = row['pokemon_id'];
      Pokemon? pokemon = await Pokemon.fromAPI(pokemonId.toString());
      if (pokemon != null) {
        stdout.writeln("- Pokémon Nombre: ${pokemon.nombre}");
        stdout.writeln("- Pokémon ID: ${pokemon.id}");
      } else {
        stdout.writeln("- Pokémon ID: $pokemonId // Nombre: Desconocido (no se pudo cargar)");
      }
    }
  }
}