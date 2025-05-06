import 'package:mysql1/mysql1.dart';
import 'pokemon_test.dart';

class Registrar {
  final MySqlConnection conn;

  Registrar(this.conn);

  Future<bool> registrar(String usuario, String contrasena) async {
    try {
      var resultados = await conn.query(
        'SELECT * FROM usuarios WHERE username = ?',
        [usuario],
      );

      if (resultados.isNotEmpty) {
        return false;
      }

      var insertResult = await conn.query(
        'INSERT INTO usuarios (username, password, nivel, exp_actual) VALUES (?, ?, 1, 0)',
        [usuario, contrasena],
      );

      int usuarioId = insertResult.insertId ?? 0;
      if (usuarioId == 0) {
        throw Exception('⚠️No se pudo obtener el ID del usuario recién creado.');
      }

      var test = TestPersonalidadPokemon();
      test.iniciar();

      String pokemonNombre = test.pokemones[test.obtenerRasgoDominante()]!;
      
      final Map<String, int> pokemonIds = {
        'Charmander': 4,
        'Mudkip': 258,
        'Psyduck': 54,
        'Bulbasaur': 1,
        'Torchic': 255,
        'Squirtle': 7,
        'Pikachu': 25,
      };

      int pokemonId = pokemonIds[pokemonNombre] ?? 1;

      await conn.query(
        'INSERT INTO inventario_pokemons (usuario_id, pokemon_id) VALUES (?, ?)',
        [usuarioId, pokemonId],
      );

      await conn.query(
        'INSERT INTO usuario_activo (usuario_id, pokemon_id) VALUES (?, ?)',
        [usuarioId, pokemonId],
      );

      return true;
    } catch (e) {
      throw Exception('⚠️Error al registrar usuario: $e');
    }
  }
}