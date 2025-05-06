import 'dart:async';
import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'pokemon.dart';

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
        stdout.write("Elige una opción: ");
        String? opcion = stdin.readLineSync();
        if (opcion == null || opcion.trim().isEmpty) {
          stdout.writeln("❌ Entrada inválida.");
          continue;
        }

        switch (opcion) {
          case '1':
            stdout.writeln("⚠️ Esta función ha sido deshabilitada.");
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

}