import 'package:mysql1/mysql1.dart';

class DBConnection {
  static Future<MySqlConnection> getConnection() async {
    try {
      var settings = ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'root',
        // password: '',
        db: 'pokeapi',
      );

      return await MySqlConnection.connect(settings);
    } catch (e) {
      throw Exception('Error al conectar a la base de datos: $e');
    }
  }

  static Future<void> closeConnection(MySqlConnection conn) async {
    try {
      await conn.close();
    } catch (e) {
      throw Exception('Error al cerrar conexión: $e');
    }
  }
}