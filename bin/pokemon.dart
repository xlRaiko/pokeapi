import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class Pokemon {
  final int id;
  final String nombre;
  int hp;
  int maxHp;
  int ataque;
  int defensa;
  int ataqueEspecial;
  int defensaEspecial;
  int velocidad;
  List<String> tipos;
  List<Habilidad> habilidades;
  List<Movimiento> movimientos;

  Pokemon({
    required this.id,
    required this.nombre,
    required this.hp,
    required this.maxHp,
    required this.ataque,
    required this.defensa,
    required this.ataqueEspecial,
    required this.defensaEspecial,
    required this.velocidad,
    required this.tipos,
    required this.habilidades,
    required this.movimientos,
  });

  void recibirDanio(int danio) {
    hp -= danio;
    if (hp < 0) hp = 0;
  }

  static Future<Pokemon?> fromAPI(String nombre) async {
    try {
      Uri url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$nombre');
      var respuesta = await http.get(url);

      if (respuesta.statusCode != 200) {
        stdout.writeln('⚠️ Error al obtener Pokémon: ${respuesta.statusCode}');
        return null;
      }

      var datos = json.decode(respuesta.body);

      Map<String, int> stats = {};
      for (var stat in datos['stats']) {
        stats[stat['stat']['name']] = stat['base_stat'];
      }

      List<String> tipos = [];
      for (var tipo in datos['types']) {
        tipos.add(tipo['type']['name']);
      }

      List<Habilidad> habilidades = [];
      for (var ability in datos['abilities']) {
        var habilidad = await Habilidad.obtenerHabilidad(ability['ability']['name']);
        habilidades.add(habilidad);
      }

      List<Movimiento> movimientos = [];
      var moves = (datos['moves'] as List)..shuffle();
      for (var move in moves.take(4)) {
        var movimiento = await Movimiento.obtenerMovimiento(move['move']['name']);
        movimientos.add(movimiento);
      }

      if (movimientos.isEmpty) {
        movimientos.add(Movimiento(
          nombre: 'tackle',
          tipo: 'normal',
          potencia: 40,
          precision: 100,
          esEspecial: false,
        ));
      }

      return Pokemon(
        id: datos['id'],
        nombre: datos['name'],
        hp: stats['hp'] ?? 20,
        maxHp: stats['hp'] ?? 20,
        ataque: stats['attack'] ?? 10,
        defensa: stats['defense'] ?? 10,
        ataqueEspecial: stats['special-attack'] ?? 10,
        defensaEspecial: stats['special-defense'] ?? 10,
        velocidad: stats['speed'] ?? 10,
        tipos: tipos,
        habilidades: habilidades,
        movimientos: movimientos,
      );
    } catch (e) {
      stdout.writeln('⚠️ Error al obtener Pokémon: $e');
      return null;
    }
  }
}

class Habilidad {
  final String nombre;
  final String efecto;

  Habilidad({required this.nombre, required this.efecto});

  static Future<Habilidad> obtenerHabilidad(String nombre) async {
    try {
      Uri url = Uri.parse('https://pokeapi.co/api/v2/ability/$nombre');
      var respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        var datos = json.decode(respuesta.body);
        String efecto = datos['effect_entries']
                ?.firstWhere((entry) => entry['language']['name'] == 'en', orElse: () => {})['effect'] ??
            'Sin efecto disponible';
        return Habilidad(nombre: nombre, efecto: efecto);
      }
    } catch (e) {
      stdout.writeln('⚠️ Error al obtener habilidad: $e');
    }
    return Habilidad(nombre: nombre, efecto: 'Sin efecto disponible');
  }
}

class Movimiento {
  final String nombre;
  final String tipo;
  final int potencia;
  final int precision;
  final bool esEspecial;

  Movimiento({
    required this.nombre,
    required this.tipo,
    required this.potencia,
    required this.precision,
    required this.esEspecial,
  });

  static Future<Movimiento> obtenerMovimiento(String nombre) async {
    try {
      Uri url = Uri.parse('https://pokeapi.co/api/v2/move/$nombre');
      var respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        var datos = json.decode(respuesta.body);
        return Movimiento(
          nombre: nombre,
          tipo: datos['type']['name'],
          potencia: datos['power'] ?? 40,
          precision: datos['accuracy'] ?? 100,
          esEspecial: datos['damage_class']['name'] == 'special',
        );
      }
    } catch (e) {
      stdout.writeln('⚠️ Error al obtener movimiento: $e');
    }
    return Movimiento(
      nombre: nombre,
      tipo: 'normal',
      potencia: 40,
      precision: 100,
      esEspecial: false,
    );
  }
}