import 'dart:convert' show json;
import 'dart:math';
import 'package:mysql1/mysql1.dart';
import 'pokemon.dart';
import 'usuario.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class EncuentroPokemon {
  final MySqlConnection conn;
  final Usuario usuario;
  final List<int> pokemonIds;
  final Random random = Random();
  int probabilidadCaptura;

  EncuentroPokemon({
    required this.conn,
    required this.usuario,
    required this.pokemonIds,
    required this.probabilidadCaptura,
  });

  Future<void> iniciarEncuentros() async {
    stdout.writeln("\n🌿 Te adentras en la ruta y comienzas a explorar...");

    bool continuarExplorando = true;

    while (continuarExplorando) {
      try {
        int espera = random.nextInt(4) + 3;
        stdout.writeln("\n⏳ Esperando... (puede que algo aparezca en $espera segundos)");
        await Future.delayed(Duration(seconds: espera));

        int pokemonId = pokemonIds[random.nextInt(pokemonIds.length)];
        Pokemon? pokemonSalvaje = await Pokemon.fromAPI(pokemonId.toString());

        if (pokemonSalvaje == null) {
          stdout.writeln("⚠️ Error al obtener datos del Pokémon salvaje.");
          continue;
        }

        stdout.writeln("\n🔥 ¡Un ${pokemonSalvaje.nombre} salvaje apareció! 🔥");
        stdout.writeln("HP: ${pokemonSalvaje.hp} | Tipos: ${pokemonSalvaje.tipos.join(', ')}");

        Pokemon? pokemonUsuario = await obtenerPrimerPokemonVivo();

        if (pokemonUsuario == null) {
          stdout.writeln("⚠️ No tienes Pokémon con vida en tu inventario. El encuentro termina.");
          return;
        }

        stdout.writeln("Tu Pokémon: ${pokemonUsuario.nombre} (HP: ${pokemonUsuario.hp})");

        bool enCombate = true;
        int intentosCaptura = 3;

        while (enCombate) {
          stdout.writeln("\n😏 ¿Qué quieres hacer?");
          stdout.writeln("1. ⚔️ Atacar (Elegir movimiento)");
          stdout.writeln("2. 🛡️ Defenderse");
          stdout.writeln("3. 🐥 Cambiar Pokémon");
          stdout.writeln("4. 🌐 Capturar (Intentos: $intentosCaptura)");
          stdout.writeln("5. 🐾 Huir");
          stdout.writeln("6. 👋 Salir de la ruta");
          stdout.write("Elige una opción: ");
          String? opcion = stdin.readLineSync();

          if (opcion == null || opcion.trim().isEmpty) {
            stdout.writeln("⚠️ Entrada inválida. Por favor, ingresa una opción válida.");
            continue;
          }

          bool defenderse = false;

          switch (opcion) {
            case '1':
              if (pokemonUsuario == null) {
                stdout.writeln("⚠️ No tienes un Pokémon activo para atacar.");
                enCombate = false;
                break;
              }
              Movimiento? movimiento = await elegirMovimiento(pokemonUsuario);
              if (movimiento != null) {
                try {
                  
                  if (!validarParametrosDanio(pokemonUsuario, pokemonSalvaje, movimiento)) {
                    stdout.writeln("⚠️ Parámetros inválidos para calcular daño. Usando daño mínimo.");
                    pokemonSalvaje.recibirDanio(1);
                    stdout.writeln("💥 ¡${pokemonUsuario.nombre} usó ${movimiento.nombre}! Hizo 1 de daño!");
                  } else {
                    int danio = await calcularDanio(pokemonUsuario, pokemonSalvaje, movimiento);
                    pokemonSalvaje.recibirDanio(danio);
                    stdout.writeln("💥 ¡${pokemonUsuario.nombre} usó ${movimiento.nombre}! Hizo $danio de daño!");
                  }
                  stdout.writeln("HP de ${pokemonSalvaje.nombre}: ${pokemonSalvaje.hp}");
                } catch (e) {
                  stdout.writeln("⚠️ Error al calcular daño: $e. Usando daño mínimo.");
                  pokemonSalvaje.recibirDanio(1);
                  stdout.writeln("HP de ${pokemonSalvaje.nombre}: ${pokemonSalvaje.hp}");
                }
              } else {
                stdout.writeln("⚠️ No se seleccionó un movimiento válido.");
              }
              if (pokemonSalvaje.hp <= 0) {
                stdout.writeln("💀 ¡Derrotaste a ${pokemonSalvaje.nombre}!");
                await usuario.ganarExperiencia(3);
                enCombate = false;
              }
              break;

            case '2':
              stdout.writeln("🛡️ Te preparas para recibir menos daño.");
              defenderse = true;
              break;

            case '3':
              Pokemon? nuevoPokemon = await usuario.cambiarPokemon();
              if (nuevoPokemon != null) {
                pokemonUsuario = nuevoPokemon;
                stdout.writeln("🔄 ¡Has cambiado a ${pokemonUsuario.nombre}!");
              } else {
                stdout.writeln("⚠️ No tienes más Pokémon disponibles.");
              }
              break;

            case '4':
              if (intentarCaptura(pokemonSalvaje)) {
                stdout.writeln("🎉 ¡Has capturado a ${pokemonSalvaje.nombre}!");
                await guardarPokemon(usuario.id, pokemonSalvaje);
                await usuario.ganarExperiencia(5);
                enCombate = false;
              } else {
                intentosCaptura--;
                if (intentosCaptura > 0) {
                  stdout.writeln("❌ ¡${pokemonSalvaje.nombre} resistió! Intentos: $intentosCaptura");
                } else {
                  stdout.writeln("💨 ¡${pokemonSalvaje.nombre} escapó!");
                  enCombate = false;
                }
              }
              break;

            case '5':
              stdout.writeln("🏃 ¡Has escapado con éxito!");
              enCombate = false;
              break;

            case '6':
              stdout.writeln("🔙 Has decidido salir de la ruta.");
              enCombate = false;
              continuarExplorando = false;
              break;

            default:
              stdout.writeln("⚠️ Opción inválida.");
          }

          if (enCombate && pokemonSalvaje.hp > 0) {
            if (pokemonUsuario == null) {
              stdout.writeln("⚠️ No tienes un Pokémon activo. El combate termina.");
              enCombate = false;
              continuarExplorando = false;
              break;
            }

            Movimiento movimientoSalvaje = pokemonSalvaje.movimientos[random.nextInt(pokemonSalvaje.movimientos.length)];
            try {
              // Validar parámetros antes de calcular daño
              if (!validarParametrosDanio(pokemonSalvaje, pokemonUsuario, movimientoSalvaje)) {
                stdout.writeln("⚠️ Parámetros inválidos para calcular daño. Usando daño mínimo.");
                pokemonUsuario.recibirDanio(1);
                stdout.writeln("⚔️ ¡${pokemonSalvaje.nombre} usó ${movimientoSalvaje.nombre}! Hizo 1 de daño!");
              } else {
                int danio = await calcularDanio(pokemonSalvaje, pokemonUsuario, movimientoSalvaje);
                if (defenderse) {
                  danio = (danio / 2).round();
                  stdout.writeln("🛡️ ¡Defensa activada! Recibes $danio de daño.");
                }
                pokemonUsuario.recibirDanio(danio);
                stdout.writeln("⚔️ ¡${pokemonSalvaje.nombre} usó ${movimientoSalvaje.nombre}! Hizo $danio de daño!");
              }
            } catch (e) {
              stdout.writeln("⚠️ Error al calcular daño: $e. Usando daño mínimo.");
              pokemonUsuario.recibirDanio(1);
              stdout.writeln("⚔️ ¡${pokemonSalvaje.nombre} usó ${movimientoSalvaje.nombre}! Hizo 1 de daño!");
            }
            stdout.writeln("HP de ${pokemonUsuario.nombre}: ${pokemonUsuario.hp}");

            if (pokemonUsuario.hp <= 0) {
              stdout.writeln("💥 ¡Tu Pokémon ha caído!");
              pokemonUsuario = await elegirNuevoPokemon();
              if (pokemonUsuario == null) {
                stdout.writeln("⚠️ No tienes más Pokémon con vida. El encuentro termina.");
                enCombate = false;
                continuarExplorando = false;
              } else {
                stdout.writeln("💫 ¡Ahora usas a ${pokemonUsuario.nombre}!");
              }
            }
          }
        }
      } catch (e) {
        stdout.writeln("⚠️ Error durante el encuentro: $e");
      }
    }
  }

  bool validarParametrosDanio(Pokemon atacante, Pokemon defensor, Movimiento movimiento) {
    if (atacante.ataque == null || atacante.ataqueEspecial == null) {
      stdout.writeln("⚠️ Atacante (${atacante.nombre}) tiene estadísticas inválidas.");
      return false;
    }
    if (defensor.defensa == null || defensor.defensaEspecial == null || defensor.tipos.isEmpty) {
      stdout.writeln("⚠️ Defensor (${defensor.nombre}) tiene estadísticas o tipos inválidos.");
      return false;
    }
    if (movimiento.tipo == null || movimiento.tipo.isEmpty || movimiento.potencia == null) {
      stdout.writeln("⚠️ Movimiento (${movimiento.nombre}) tiene tipo o potencia inválidos.");
      return false;
    }
    return true;
  }

  Future<Movimiento?> elegirMovimiento(Pokemon pokemon) async {
    try {
      if (pokemon == null) {
        stdout.writeln("⚠️ No hay Pokémon seleccionado.");
        return null;
      }

      if (pokemon.movimientos.isEmpty) {
        stdout.writeln("⚠️ Este Pokémon no tiene movimientos disponibles.");
        return null;
      }

      stdout.writeln("\nElige un movimiento:");
      for (int i = 0; i < pokemon.movimientos.length; i++) {
        stdout.writeln("${i + 1}. ${pokemon.movimientos[i].nombre} (Tipo: ${pokemon.movimientos[i].tipo}, Potencia: ${pokemon.movimientos[i].potencia})");
      }
      stdout.write("Selecciona un movimiento (1-${pokemon.movimientos.length}): ");
      String? input = stdin.readLineSync();
      if (input == null || input.trim().isEmpty) {
        stdout.writeln("⚠️ Entrada inválida.");
        return null;
      }
      int? index = int.tryParse(input);
      if (index != null && index > 0 && index <= pokemon.movimientos.length) {
        return pokemon.movimientos[index - 1];
      }
      stdout.writeln("⚠️ Movimiento inválido.");
      return null;
    } catch (e) {
      stdout.writeln("⚠️ Error al elegir movimiento: $e");
      return null;
    }
  }

  Future<int> calcularDanio(Pokemon atacante, Pokemon defensor, Movimiento movimiento) async {
    try {

      if (movimiento.tipo == null || movimiento.tipo.isEmpty) {
        stdout.writeln("⚠️ El movimiento no tiene un tipo válido: ${movimiento.nombre}");
        return 1;
      }
      if (defensor.tipos.isEmpty) {
        stdout.writeln("⚠️ El Pokémon defensor no tiene tipos válidos: ${defensor.nombre}");
        return 1;
      }

      double multiplicador = 1.0;
      for (var tipoDefensor in defensor.tipos) {
        if (tipoDefensor == null || tipoDefensor.isEmpty) {
          stdout.writeln("⚠️ Tipo defensor inválido para ${defensor.nombre}");
          continue;
        }

        var response = await http.get(Uri.parse('https://pokeapi.co/api/v2/type/${movimiento.tipo.toLowerCase()}'));
        if (response.statusCode != 200) {
          stdout.writeln("⚠️ Error al obtener datos del tipo ${movimiento.tipo} desde la PokeAPI");
          continue;
        }

        var datos = json.decode(response.body)['damage_relations'];

        // Verificar fortalezas (x2)
        if (datos['double_damage_to'].any((t) => t['name'] == tipoDefensor.toLowerCase())) {
          multiplicador *= 2.0;
        }
        // Verificar resistencias (x0.5)
        if (datos['half_damage_to'].any((t) => t['name'] == tipoDefensor.toLowerCase())) {
          multiplicador *= 0.5;
        }
        // Verificar inmunidades (x0)
        if (datos['no_damage_to'].any((t) => t['name'] == tipoDefensor.toLowerCase())) {
          multiplicador *= 0.0;
        }
      }

      int ataque = movimiento.esEspecial ? atacante.ataqueEspecial : atacante.ataque;
      int defensa = movimiento.esEspecial ? defensor.defensaEspecial : defensor.defensa;
      if (ataque <= 0 || defensa <= 0 || movimiento.potencia <= 0) {
        stdout.writeln("⚠️ Estadísticas inválidas: ataque=$ataque, defensa=$defensa, potencia=${movimiento.potencia}");
        return 1;
      }

      int danio = ((2 * ataque * movimiento.potencia / defensa / 50) * multiplicador * (random.nextInt(16) + 85) / 100).round();
      return danio > 0 ? danio : 1;
    } catch (e) {
      stdout.writeln("⚠️ Error al calcular daño: $e");
      return 1;
    }
  }

  bool intentarCaptura(Pokemon pokemon) {
    try {
      double captureRate = (3 * pokemon.maxHp - 2 * pokemon.hp) * probabilidadCaptura / (3 * pokemon.maxHp) / 100;
      return random.nextDouble() < captureRate;
    } catch (e) {
      stdout.writeln("⚠️ Error al intentar captura: $e");
      return false;
    }
  }

  Future<Pokemon?> obtenerPrimerPokemonVivo() async {
    try {
      // Obtener todos los Pokémon del inventario (máximo 6)
      var results = await conn.query(
        'SELECT pokemon_id FROM inventario_pokemons WHERE usuario_id = ? LIMIT 6',
        [usuario.id],
      );

      if (results.isEmpty) {
        stdout.writeln("⚠️ No tienes Pokémon en tu inventario.");
        return null;
      }

      for (var row in results) {
        int pokemonId = row['pokemon_id'];
        Pokemon? pokemon = await Pokemon.fromAPI(pokemonId.toString());
        if (pokemon == null) {
          stdout.writeln("⚠️ No se pudo cargar el Pokémon con ID: $pokemonId.");
          continue;
        }
        if (pokemon.hp > 0) {
          var existing = await conn.query(
            'SELECT * FROM usuario_activo WHERE usuario_id = ?',
            [usuario.id],
          );
          if (existing.isNotEmpty) {
            await conn.query(
              'UPDATE usuario_activo SET pokemon_id = ? WHERE usuario_id = ?',
              [pokemon.id, usuario.id],
            );
          } else {
            await conn.query(
              'INSERT INTO usuario_activo (usuario_id, pokemon_id) VALUES (?, ?)',
              [usuario.id, pokemon.id],
            );
          }
          stdout.writeln("✅ ¡${pokemon.nombre} ha sido seleccionado como tu Pokémon activo!");
          return pokemon;
        }
      }

      stdout.writeln("⚠️ Todos tus Pokémon están debilitados.");
      return null;
    } catch (e) {
      stdout.writeln("⚠️ Error al obtener Pokémon activo: $e");
      return null;
    }
  }

  Future<void> guardarPokemon(int usuarioId, Pokemon pokemon) async {
    try {
      var result = await conn.query(
        'SELECT COUNT(*) as cantidad FROM inventario_pokemons WHERE usuario_id = ?',
        [usuarioId],
      );

      int cantidad = result.first['cantidad'];

      if (cantidad >= 6) {
        await conn.query(
          'INSERT INTO caja_pokemons (usuario_id, pokemon_id) VALUES (?, ?)',
          [usuarioId, pokemon.id],
        );
        stdout.writeln("✅ ¡${pokemon.nombre} ha sido guardado en tu caja porque el inventario está lleno!");
      } else {
        await conn.query(
          'INSERT INTO inventario_pokemons (usuario_id, pokemon_id) VALUES (?, ?)',
          [usuarioId, pokemon.id],
        );
        stdout.writeln("✅ ¡${pokemon.nombre} ha sido guardado en tu inventario!");
      }
    } catch (e) {
      stdout.writeln("⚠️ Error al guardar Pokémon: $e");
    }
  }

  Future<Pokemon?> elegirNuevoPokemon() async {
    try {
      var results = await conn.query(
        'SELECT i.pokemon_id FROM inventario_pokemons i WHERE i.usuario_id = ?',
        [usuario.id],
      );

      List<Pokemon> pokemonsVivos = [];
      for (var row in results) {
        Pokemon? pokemon = await Pokemon.fromAPI(row['pokemon_id'].toString());
        if (pokemon != null && pokemon.hp > 0) {
          pokemonsVivos.add(pokemon);
        }
      }

      if (pokemonsVivos.isEmpty) {
        stdout.writeln("⚠️ No tienes Pokémon vivos en tu inventario.");
        return null;
      }

      stdout.writeln("Elige un nuevo Pokémon:");
      for (int i = 0; i < pokemonsVivos.length; i++) {
        stdout.writeln("${i + 1}. ${pokemonsVivos[i].nombre} (HP: ${pokemonsVivos[i].hp})");
      }
      stdout.write("Selecciona un Pokémon (1-${pokemonsVivos.length}): ");
      String? input = stdin.readLineSync();
      if (input == null || input.trim().isEmpty) {
        stdout.writeln("⚠️ Entrada inválida.");
        return null;
      }
      int? index = int.tryParse(input);
      if (index != null && index > 0 && index <= pokemonsVivos.length) {
        var selectedPokemon = pokemonsVivos[index - 1];

        var existing = await conn.query('SELECT * FROM usuario_activo WHERE usuario_id = ?', [usuario.id]);
        if (existing.isNotEmpty) {
          await conn.query(
            'UPDATE usuario_activo SET pokemon_id = ? WHERE usuario_id = ?',
            [selectedPokemon.id, usuario.id],
          );
        } else {
          await conn.query(
            'INSERT INTO usuario_activo (usuario_id, pokemon_id) VALUES (?, ?)',
            [usuario.id, selectedPokemon.id],
          );
        }
        return selectedPokemon;
      }
      stdout.writeln("⚠️ Selección inválida.");
      return null;
    } catch (e) {
      stdout.writeln("⚠️ Error al elegir nuevo Pokémon: $e");
      return null;
    }
  }
}