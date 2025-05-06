import 'package:mysql1/mysql1.dart';

class Login {
  final MySqlConnection conn;

  Login(this.conn);

  Future<bool> autenticarUsuario(String usuario, String contrasena) async {
    try {
      var results = await conn.query(
        'SELECT * FROM usuarios WHERE username = ? AND password = ?',
        [usuario, contrasena]
      );
      return results.isNotEmpty;
    } catch (e) {
      throw Exception('Error al autenticar usuario: $e');
    }
  }
}