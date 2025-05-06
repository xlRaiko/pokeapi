import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'inventario.dart';
import 'pokemon.dart';

class Comandos {
  final MySqlConnection conn;
  final int usuarioId;
  final Inventario inventario;

  Comandos({required this.conn, required this.usuarioId})
      : inventario = Inventario(conn: conn);

  Future<void> ejecutarComando(String comando) async {
    try {
      List<String> partes = comando.split(' ');
      if (partes.isEmpty) {
        stdout.writeln('⚠️ Comando inválido');
        return;
      }

      String accion = partes[0];

      switch (accion) {
        case ':obtener':
          if (partes.length < 2) {
            stdout.writeln('⚠️ Uso: :obtener <pokemon_id>');
            return;
          }
          int? pokemonId = int.tryParse(partes[1]);
          if (pokemonId == null) {
            stdout.writeln('⚠️ ID de Pokémon inválido');
            return;
          }
          await agregarPokemonAlInventario(pokemonId);
          break;

        case ':verinventario':
          await inventario.verInventario(usuarioId);
          break;

        case ':vercaja':
          await inventario.verCaja(usuarioId);
          break;

        case ':liberar':
          if (partes.length < 2) {
            stdout.writeln('⚠️ Uso: :liberar <pokemon_id>');
            return;
          }
          int? pokemonIdLiberar = int.tryParse(partes[1]);
          if (pokemonIdLiberar == null) {
            stdout.writeln('⚠️ ID de Pokémon inválido');
            return;
          }
          await liberarPokemon(pokemonIdLiberar);
          break;

        case ':exp':
          if (partes.length < 2) {
            stdout.writeln('⚠️ Uso: :exp <cantidad>');
            return;
          }
          int? cantidadExp = int.tryParse(partes[1]);
          if (cantidadExp == null) {
            stdout.writeln('⚠️ Cantidad de experiencia inválida');
            return;
          }
          await agregarExperiencia(cantidadExp);
          break;

        case ':dexp':
          if (partes.length < 2) {
            stdout.writeln('⚠️ Uso: :dexp <cantidad>');
            return;
          }
          int? cantidadDexp = int.tryParse(partes[1]);
          if (cantidadDexp == null) {
            stdout.writeln('⚠️ Cantidad de experiencia inválida');
            return;
          }
          await quitarExperiencia(cantidadDexp);
          break;

        case ':salir':
          exit(0);

        default:
          stdout.writeln('⚠️ Comando desconocido');
      }
    } catch (e) {
      stdout.writeln('⚠️ Error ejecutando comando: $e');
    }
  }

  Future<void> agregarPokemonAlInventario(int pokemonId) async {
    try {
      // Verificar que el Pokémon existe en la PokeAPI
      Pokemon? pokemon = await Pokemon.fromAPI(pokemonId.toString());
      if (pokemon == null) {
        stdout.writeln('⚠️ No se pudo obtener el Pokémon con ID $pokemonId desde la PokeAPI');
        return;
      }

      // Verificar la cantidad de Pokémon en el inventario
      var result = await conn.query(
        'SELECT COUNT(*) as cantidad FROM inventario_pokemons WHERE usuario_id = ?',
        [usuarioId],
      );

      int cantidad = result.first['cantidad'];

      if (cantidad >= 6) {
        await conn.query(
          'INSERT INTO caja_pokemons (usuario_id, pokemon_id) VALUES (?, ?)',
          [usuarioId, pokemonId],
        );
        stdout.writeln('📦 Pokémon ${pokemon.nombre} (ID: $pokemonId) añadido a la caja porque el inventario está lleno');
      } else {
        await conn.query(
          'INSERT INTO inventario_pokemons (usuario_id, pokemon_id) VALUES (?, ?)',
          [usuarioId, pokemonId],
        );
        stdout.writeln('🎒 Pokémon ${pokemon.nombre} (ID: $pokemonId) añadido al inventario');
      }
    } catch (e) {
      stdout.writeln('⚠️ Error añadiendo Pokémon: $e');
    }
  }

  Future<void> liberarPokemon(int pokemonId) async {
    try {
      var result = await conn.query(
        'SELECT * FROM inventario_pokemons WHERE usuario_id = ? AND pokemon_id = ?',
        [usuarioId, pokemonId],
      );

      if (result.isEmpty) {
        stdout.writeln('⚠️ Pokémon con ID $pokemonId no encontrado en el inventario');
        return;
      }

      await conn.query(
        'DELETE FROM inventario_pokemons WHERE usuario_id = ? AND pokemon_id = ?',
        [usuarioId, pokemonId],
      );
      stdout.writeln('🕊️ Pokémon con ID $pokemonId liberado del inventario');
    } catch (e) {
      stdout.writeln('⚠️ Error liberando Pokémon: $e');
    }
  }

  Future<void> agregarExperiencia(int cantidad) async {
    try {
      var result = await conn.query(
        'SELECT exp_actual FROM usuarios WHERE id = ?',
        [usuarioId],
      );

      if (result.isEmpty) {
        stdout.writeln('⚠️ Usuario no encontrado');
        return;
      }

      int expActual = result.first['exp_actual'];
      int nuevaExp = expActual + cantidad;

      await conn.query(
        'UPDATE usuarios SET exp_actual = ? WHERE id = ?',
        [nuevaExp, usuarioId],
      );
      stdout.writeln('📈 Añadidos $cantidad puntos de experiencia');
    } catch (e) {
      stdout.writeln('⚠️ Error añadiendo experiencia: $e');
    }
  }

  Future<void> quitarExperiencia(int cantidad) async {
    try {
      var result = await conn.query(
        'SELECT exp_actual FROM usuarios WHERE id = ?',
        [usuarioId],
      );

      if (result.isEmpty) {
        stdout.writeln('⚠️ Usuario no encontrado');
        return;
      }

      int expActual = result.first['exp_actual'];
      int nuevaExp = expActual - cantidad;

      if (nuevaExp < 0) {
        stdout.writeln('⚠️ No puedes quitar más experiencia de la disponible');
        return;
      }

      await conn.query(
        'UPDATE usuarios SET exp_actual = ? WHERE id = ?',
        [nuevaExp, usuarioId],
      );
      stdout.writeln('📉 Retirados $cantidad puntos de experiencia');
    } catch (e) {
      stdout.writeln('⚠️ Error retirando experiencia: $e');
    }
  }
}