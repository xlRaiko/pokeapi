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
      );
    } catch (e) {
      stdout.writeln('⚠️ Error al obtener Pokémon: $e');
      return null;
    }
  }
}