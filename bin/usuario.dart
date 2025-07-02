import 'dart:async';
import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'pokemon.dart';
import 'encuentroPokemon.dart';
import 'experiencia.dart';

class Usuario {
  final MySqlConnection conn;
  int id;
  String nombre;
  int nivel;
  int expActual;
  List<Pokemon> inventario;

  Usuario({
    required this.conn,
    required this.id,
    required this.nombre,
    required this.nivel,
    required this.expActual,
  }) : inventario = [];

  Future<void> inicializarInventario() async {
    try {
      var results = await conn.query('SELECT pokemon_id FROM inventario_pokemons WHERE usuario_id = ?', [id]);
      inventario = [];
      
      for (var row in results) {
        int pokemonId = row['pokemon_id'];
        Pokemon? pokemon = await obtenerPokemon(pokemonId);
        if (pokemon != null) {
          inventario.add(pokemon);
        }
      }
    } catch (e) {
      stdout.writeln("⚠️ Error al inicializar inventario: $e");
    }
  }

  Future<void> ganarExperiencia(int cantidad) async {
    try {
      Experiencia experiencia = Experiencia(conn: conn);
      await experiencia.otorgarExperiencia(id, cantidad);
      // Actualizar los valores locales
      var result = await conn.query(
        'SELECT nivel, exp_actual FROM usuarios WHERE id = ?',
        [id]
      );
      if (result.isNotEmpty) {
        nivel = result.first['nivel'];
        expActual = result.first['exp_actual'];
      }
    } catch (e) {
      stdout.writeln("⚠️ Error al ganar experiencia: $e");
    }
  }

  Future<Pokemon?> cambiarPokemon() async {
    try {
      var results = await conn.query('SELECT pokemon_id FROM inventario_pokemons WHERE usuario_id = ?', [id]);
      
      if (results.isEmpty) {
        stdout.writeln("⚠️ No tienes Pokémon en tu inventario.");
        return null;
      }

      stdout.writeln("Selecciona un nuevo Pokémon de tu inventario:");
      List<Pokemon> pokemons = [];
      for (var row in results) {
        int pokemonId = row['pokemon_id'];
        Pokemon? pokemon = await obtenerPokemon(pokemonId);
        if (pokemon != null) {
          pokemons.add(pokemon);
          stdout.writeln("${pokemons.length}. ${pokemon.nombre}");
        }
      }

      stdout.write("Elige un Pokémon para activar (número): ");
      String? opcion = stdin.readLineSync();
      if (opcion == null || opcion.trim().isEmpty) {
        stdout.writeln("❌ Entrada inválida.");
        return null;
      }

      int? index = int.tryParse(opcion);
      if (index != null && index > 0 && index <= pokemons.length) {
        Pokemon pokemonSeleccionado = pokemons[index - 1];
        var existing = await conn.query('SELECT * FROM usuario_activo WHERE usuario_id = ?', [id]);
        if (existing.isNotEmpty) {
          await conn.query('UPDATE usuario_activo SET pokemon_id = ? WHERE usuario_id = ?', [pokemonSeleccionado.id, id]);
        } else {
          await conn.query('INSERT INTO usuario_activo (usuario_id, pokemon_id) VALUES (?, ?)', [id, pokemonSeleccionado.id]);
        }
        stdout.writeln("¡Ahora tu Pokémon activo es ${pokemonSeleccionado.nombre}!");
        return pokemonSeleccionado;
      } else {
        stdout.writeln("❌ Opción inválida. No existe ese Pokémon.");
        return null;
      }
    } catch (e) {
      stdout.writeln("⚠️ Error al cambiar Pokémon: $e");
      return null;
    }
  }

  Future<void> asignarPokemonActivo() async {
    try {
      var results = await conn.query('SELECT pokemon_id FROM inventario_pokemons WHERE usuario_id = ?', [id]);

      if (results.isEmpty) {
        stdout.writeln("⚠️ No tienes Pokémon en tu inventario.");
        return;
      }

      int pokemonId = results.first['pokemon_id'];
      Pokemon? pokemon = await obtenerPokemon(pokemonId);

      if (pokemon != null) {
        var existing = await conn.query('SELECT * FROM usuario_activo WHERE usuario_id = ?', [id]);
        if (existing.isNotEmpty) {
          await conn.query('UPDATE usuario_activo SET pokemon_id = ? WHERE usuario_id = ?', [pokemon.id, id]);
        } else {
          await conn.query('INSERT INTO usuario_activo (usuario_id, pokemon_id) VALUES (?, ?)', [id, pokemon.id]);
        }
        stdout.writeln("¡Tu Pokémon activo es ahora ${pokemon.nombre}!");
      }
    } catch (e) {
      stdout.writeln("⚠️ Error al asignar Pokémon activo: $e");
    }
  }

  Future<Pokemon?> obtenerPokemonActivo() async {
    try {
      var results = await conn.query('SELECT pokemon_id FROM usuario_activo WHERE usuario_id = ?', [id]);

      if (results.isEmpty) {
        stdout.writeln("⚠️ No tienes un Pokémon activo asignado.");
        return null;
      }

      int pokemonId = results.first['pokemon_id'];
      return await obtenerPokemon(pokemonId);
    } catch (e) {
      stdout.writeln("⚠️ Error al obtener Pokémon activo: $e");
      return null;
    }
  }

  Future<void> mostrarRutasDisponibles() async {
    try {
      var results = await conn.query('SELECT * FROM rutas');

      if (results.isEmpty) {
        stdout.writeln("⚠️ No hay rutas disponibles.");
        return;
      }

      stdout.writeln("🌍 Rutas disponibles:");
      List<Map<String, dynamic>> rutas = [];
      for (var row in results) {
        int nivelRequerido = row['nivel_minimo'] ?? 10;

        if (nivelRequerido <= nivel) {
          rutas.add({
            'id': row['id'],
            'nombre': row['nombre'],
            'nivel_minimo': nivelRequerido,
          });
          stdout.writeln("- Ruta: ${row['nombre']} (ID: ${row['id']}) | Nivel requerido: $nivelRequerido");
        }
      }

      if (rutas.isEmpty) {
        stdout.writeln("⚠️ No tienes acceso a ninguna ruta por tu nivel.");
        return;
      }

      bool continuarEnRutas = true;
      while (continuarEnRutas) {
        stdout.writeln("\n¿Qué deseas hacer?");
        stdout.writeln("1. 🐾 Acceder a una ruta");
        stdout.writeln("2. 👋 Salir del menú de rutas");
        stdout.writeln("");
        stdout.write("Elige una opción: ");
        stdout.writeln("");
        String? opcion = stdin.readLineSync();
        if (opcion == null || opcion.trim().isEmpty) {
          stdout.writeln("❌ Entrada inválida.");
          continue;
        }

        switch (opcion) {
          case '1':
            stdout.write("Ingresa el ID de la ruta a la que deseas acceder: ");
            String? rutaIdInput = stdin.readLineSync();
            if (rutaIdInput == null || rutaIdInput.trim().isEmpty) {
              stdout.writeln("❌ Entrada inválida.");
              continue;
            }
            int? rutaId = int.tryParse(rutaIdInput);
            if (rutaId == null) {
              stdout.writeln("❌ ID de ruta inválido.");
              continue;
            }
            bool rutaValida = rutas.any((ruta) => ruta['id'] == rutaId);

            if (rutaValida) {
              stdout.writeln("🚶‍♂️ Accediendo a la ruta ${rutas.firstWhere((ruta) => ruta['id'] == rutaId)['nombre']}...");
              var encuentro = EncuentroPokemon(
                conn: conn,
                usuario: this,
                pokemonIds: await obtenerPokemonDeRuta(rutaId),
                probabilidadCaptura: await obtenerProbabilidadCaptura(rutaId),
              );
              await encuentro.iniciarEncuentros();
              continuarEnRutas = false;
            } else {
              stdout.writeln("❌ Ruta no válida.");
            }
            break;

          case '2':
            stdout.writeln("🔙 Regresando al menú principal...");
            continuarEnRutas = false;
            break;

          default:
            stdout.writeln("❌ Opción inválida. Intenta de nuevo.");
            break;
        }
      }
    } catch (e) {
      stdout.writeln("⚠️ Error al obtener las rutas: $e");
    }
  }

  Future<List<int>> obtenerPokemonDeRuta(int rutaId) async {
    try {
      var results = await conn.query('SELECT pokemon_ids FROM rutas WHERE id = ?', [rutaId]);

      if (results.isEmpty) {
        stdout.writeln("⚠️ Ruta no encontrada.");
        return [];
      }

      var row = results.first;
      String pokemonIdsString = row['pokemon_ids'] ?? '';
      if (pokemonIdsString.isEmpty) {
        stdout.writeln("⚠️ No se han asignado Pokémon a esta ruta.");
        return [];
      }

      List<String> pokemonIdsList = pokemonIdsString.split(',');
      List<int> pokemonIds = pokemonIdsList.map((idStr) => int.parse(idStr)).toList();
      return pokemonIds;
    } catch (e) {
      stdout.writeln("⚠️ Error al obtener los Pokémon de la ruta: $e");
      return [];
    }
  }

  Future<int> obtenerProbabilidadCaptura(int rutaId) async {
    try {
      var results = await conn.query('SELECT probabilidad_captura FROM rutas WHERE id = ?', [rutaId]);
      if (results.isEmpty) {
        stdout.writeln("⚠️ Ruta no encontrada, probabilidad de captura por defecto.");
        return 50;
      }
      var row = results.first;
      var probabilidad = row['probabilidad_captura'];
      return probabilidad ?? 50;
    } catch (e) {
      stdout.writeln("⚠️ Error al obtener probabilidad de captura: $e");
      return 50;
    }
  }

  Future<Pokemon?> obtenerPokemon(int pokemonId) async {
    try {
      Pokemon? pokemon = await Pokemon.fromAPI(pokemonId.toString());
      if (pokemon == null) {
        stdout.writeln("⚠️ Pokémon no encontrado.");
        return null;
      }
      return pokemon;
    } catch (e) {
      stdout.writeln("⚠️ Error al obtener Pokémon: $e");
      return null;
    }
  }
}