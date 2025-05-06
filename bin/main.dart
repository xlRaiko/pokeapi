import 'dart:io';
import 'db_conexion.dart';
import 'login.dart';
import 'registrar.dart';
import 'menu_principal.dart';
import 'db_crear.dart';

void main() async {
  try {
    await DBInitializer.init();

    var conn = await DBConnection.getConnection();

    var login = Login(conn);
    var registrar = Registrar(conn);

    bool continuar = true;

    var menuPrincipal = MenuPrincipal(conn: conn, login: login, registrar: registrar);

    while (continuar) {
      continuar = await menuPrincipal.mostrarMenu();
    }

    await conn.close();
  } catch (e) {
    stdout.writeln("⚠️ Error: $e");
  }
}