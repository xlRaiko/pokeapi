import 'dart:io';
import 'login.dart';
import 'registrar.dart';
import 'menu_juego.dart';
import 'package:mysql1/mysql1.dart';
import 'usuario.dart';

class MenuPrincipal {
  final MySqlConnection conn;
  final Login login;
  final Registrar registrar;

  MenuPrincipal({required this.conn, required this.login, required this.registrar});

  Future<bool> mostrarMenu() async {
    stdout.writeln("📩 Menu:");
    stdout.writeln("");
    stdout.writeln("1. 📥 Logearse");
    stdout.writeln("2. 📋 Registrarse");
    stdout.writeln("3. 👋 Salir");
    stdout.write("Elige una opción (1, 2, 3): ");
    String? opcion = stdin.readLineSync();

    switch (opcion) {
      case '1':
        await realizarLogin();
        return true;

      case '2':
        await registrarUsuario();
        return true;

      case '3':
        stdout.writeln("👋¡Hasta luego!");
        return false;

      default:
        stdout.writeln("⚠️Opción inválida, por favor elige 1, 2 o 3.");
        return true;
    }
  }

  Future<void> realizarLogin() async {
    stdout.writeln("💁Introduce tu nombre de usuario:");
    String? usuario = stdin.readLineSync();
    stdout.writeln("📋Introduce tu contraseña:");
    String? contrasena = stdin.readLineSync();

    if (usuario == null || contrasena == null || usuario.isEmpty || contrasena.isEmpty) {
      stdout.writeln("⚠️ Usuario o contraseña no pueden estar vacíos.");
      return;
    }

    try {
      var results = await conn.query(
        'SELECT * FROM usuarios WHERE username = ?',
        [usuario],
      );

      if (results.isEmpty) {
        stdout.writeln("⚠️Usuario no encontrado.");
        return;
      }

      var userRow = results.first;

      var usuarioInstancia = Usuario(
        conn: conn,
        id: userRow['id'],
        nombre: userRow['username'] ?? 'Desconocido',
        nivel: userRow['nivel'] ?? 1,
        expActual: userRow['exp_actual'] ?? 0,
      );

      bool autenticado = await login.autenticarUsuario(usuario, contrasena);

      if (autenticado) {
        stdout.writeln("👋¡Bienvenido, ${usuarioInstancia.nombre}!");
        
        var menuJuego = MenuJuego(conn: conn, usuarioInstancia: usuarioInstancia);
        await menuJuego.mostrarMenu();
      } else {
        stdout.writeln("⚠️Usuario o contraseña incorrectos.");
      }
    } catch (e) {
      stdout.writeln("⚠️ Error al realizar login: $e");
    }
  }

  Future<void> registrarUsuario() async {
    stdout.writeln("📋Introduce un nombre de usuario para registrarte:");
    String? usuario = stdin.readLineSync();
    stdout.writeln();
    stdout.writeln("📋Introduce una contraseña:");
    String? contrasena = stdin.readLineSync();
    stdout.writeln();

    if (usuario == null || contrasena == null || usuario.isEmpty || contrasena.isEmpty) {
      stdout.writeln("⚠️ Usuario o contraseña no pueden estar vacíos.");
      return;
    }

    try {
      bool registrado = await registrar.registrar(usuario, contrasena);

      if (registrado) {
        stdout.writeln("✅¡Usuario registrado con éxito!✅ Se ha asignado tu Pokémon inicial tras el test de personalidad.");
      } else {
        stdout.writeln("⚠️El nombre de usuario ya está registrado.");
      }
    } catch (e) {
      stdout.writeln("⚠️ Error al registrar usuario: $e");
    }
  }
}