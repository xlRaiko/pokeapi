import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> mostrarFortalezas(List<String> tipos) async {
  try {
    if (tipos.isEmpty) {
      stdout.writeln("⚠️ Este Pokémon no tiene tipos definidos.");
      return;
    }

    stdout.writeln("\n🔥 Fortalezas y resistencias del Pokémon:");
    stdout.writeln();

    Set<String> tiposFuertesX2 = {};
    Set<String> tiposFuertesX4 = {};
    Set<String> tiposResistentesX05 = {};
    Set<String> tiposResistentesX025 = {};
    Set<String> tiposInmunes = {};

    for (String tipo in tipos) {
      var response = await http.get(Uri.parse('https://pokeapi.co/api/v2/type/$tipo'));
      if (response.statusCode != 200) {
        stdout.writeln("⚠️ Error al obtener datos del tipo $tipo desde la PokeAPI.");
        continue;
      }

      var datos = json.decode(response.body)['damage_relations'];

      // Fortalezas (hace daño x2)
      for (var t in datos['double_damage_to']) {
        tiposFuertesX2.add(t['name']);
      }

      // Resistencias (recibe daño x0.5)
      for (var t in datos['half_damage_from']) {
        tiposResistentesX05.add(t['name']);
      }

      // Debilidades (recibe daño x2)
      for (var t in datos['double_damage_from']) {
        tiposFuertesX2.add(t['name']);
      }

      // Inmunidades (recibe daño x0)
      for (var t in datos['no_damage_from']) {
        tiposInmunes.add(t['name']);
      }
    }

    if (tipos.length > 1) {
      var response2 = await http.get(Uri.parse('https://pokeapi.co/api/v2/type/${tipos[1]}'));
      if (response2.statusCode == 200) {
        var datos2 = json.decode(response2.body)['damage_relations'];

        Set<String> tempFuertesX2 = {};
        Set<String> tempResistentesX05 = {};

        for (var t in datos2['double_damage_to']) {
          if (tiposFuertesX2.contains(t['name'])) {
            tiposFuertesX4.add(t['name']);
          } else {
            tempFuertesX2.add(t['name']);
          }
        }

        for (var t in datos2['half_damage_from']) {
          if (tiposResistentesX05.contains(t['name'])) {
            tiposResistentesX025.add(t['name']);
          } else {
            tempResistentesX05.add(t['name']);
          }
        }

        for (var t in datos2['double_damage_from']) {
          if (tiposResistentesX05.contains(t['name'])) {
            tiposResistentesX05.remove(t['name']);
          } else {
            tempFuertesX2.add(t['name']);
          }
        }

        for (var t in datos2['no_damage_from']) {
          tiposInmunes.add(t['name']);
        }

        // Actualizar conjuntos
        tiposFuertesX2.addAll(tempFuertesX2);
        tiposResistentesX05.addAll(tempResistentesX05);
      }
    }

    // Eliminar duplicados y conflictos
    tiposFuertesX2.removeWhere((tipo) => tiposFuertesX4.contains(tipo));
    tiposResistentesX05.removeWhere((tipo) => tiposResistentesX025.contains(tipo));
    tiposFuertesX2.removeWhere((tipo) => tiposInmunes.contains(tipo));
    tiposResistentesX05.removeWhere((tipo) => tiposInmunes.contains(tipo));
    tiposFuertesX4.removeWhere((tipo) => tiposInmunes.contains(tipo));
    tiposResistentesX025.removeWhere((tipo) => tiposInmunes.contains(tipo));

    // Mostrar resultados
    if (tiposFuertesX4.isNotEmpty) {
      stdout.write("💥 Hace x4 de daño contra: ");
      stdout.writeln(tiposFuertesX4.map((t) => t.capitalize()).join(", "));
    } else {
      stdout.writeln("⚠️ No tiene fortalezas x4.");
    }

    if (tiposFuertesX2.isNotEmpty) {
      stdout.write("💥 Hace x2 de daño contra: ");
      stdout.writeln(tiposFuertesX2.map((t) => t.capitalize()).join(", "));
    } else {
      stdout.writeln("⚠️ No tiene fortalezas x2.");
    }

    if (tiposResistentesX025.isNotEmpty) {
      stdout.write("🛡️ Recibe x0.25 de daño de: ");
      stdout.writeln(tiposResistentesX025.map((t) => t.capitalize()).join(", "));
    } else {
      stdout.writeln("⚠️ No tiene resistencias x0.25.");
    }

    if (tiposResistentesX05.isNotEmpty) {
      stdout.write("🛡️ Recibe x0.5 de daño de: ");
      stdout.writeln(tiposResistentesX05.map((t) => t.capitalize()).join(", "));
    } else {
      stdout.writeln("⚠️ No tiene resistencias x0.5.");
    }

    if (tiposInmunes.isNotEmpty) {
      stdout.write("🛡️ Inmune a: ");
      stdout.writeln(tiposInmunes.map((t) => t.capitalize()).join(", "));
    } else {
      stdout.writeln("⚠️ No tiene inmunidades.");
    }
  } catch (e) {
    stdout.writeln("⚠️ Error al mostrar fortalezas: $e");
  }
}

// Extensión para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}