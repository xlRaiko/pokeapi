import 'package:mysql1/mysql1.dart';

class Experiencia {
  final MySqlConnection conn;

  Experiencia({required this.conn});

  Future<int> obtenerExpNecesaria(int nivel) async {
    try {
      // Cada nivel requiere 100 EXP más que el anterior
      return nivel * 100;
    } catch (e) {
      print('ERROR: al obtener la experiencia requerida: $e');
      rethrow;
    }
  }

  Future<void> otorgarExperiencia(int usuarioId, int expGanada) async {
    try {
      var results = await conn.query(
        'SELECT exp_actual, nivel FROM usuarios WHERE id = ?',
        [usuarioId],
      );
      if (results.isEmpty) {
        print('ERROR: Usuario no encontrado: $usuarioId');
        throw Exception('Usuario no encontrado');
      }

      var row = results.first;
      int expActual = row['exp_actual'];
      int nivelActual = row['nivel'];
      int nuevaExp = expActual + expGanada;

      while (true) {
        int expNecesaria = await obtenerExpNecesaria(nivelActual);
        if (nuevaExp >= expNecesaria) {
          nuevaExp -= expNecesaria;
          nivelActual++;
          print('¡Felicidades! Subiste al nivel $nivelActual');
        } else {
          break;
        }
      }

      await conn.query(
        'UPDATE usuarios SET exp_actual = ?, nivel = ? WHERE id = ?',
        [nuevaExp, nivelActual, usuarioId],
      );
      print('Experiencia actualizada: $nuevaExp EXP, Nivel: $nivelActual');
    } catch (e) {
      print('ERROR: al otorgar experiencia: $e');
    }
  }
}