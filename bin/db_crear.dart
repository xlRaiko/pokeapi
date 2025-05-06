import 'package:mysql1/mysql1.dart';
import 'db_conexion.dart';

class DBInitializer {
  static Future<void> init() async {
    var settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      // password: '',
    );
    
    var conn = await MySqlConnection.connect(settings);
    
    try {
      bool existe = await verificarBaseDeDatos(conn);

      if (!existe) {
        await crearBaseDeDatos(conn);
        await conn.close();
        conn = await DBConnection.getConnection();
        await cargarEstructuraDeDatos(conn);
      }
    } finally {
      await conn.close();
    }
  }

  static Future<bool> verificarBaseDeDatos(MySqlConnection conn) async {
    try {
      var result = await conn.query('SHOW DATABASES LIKE "pokeapi"');
      return result.isNotEmpty;
    } catch (e) {
      print("⚠️Error verificando base de datos: $e");
      return false;
    }
  }

  static Future<void> crearBaseDeDatos(MySqlConnection conn) async {
    try {
      await conn.query('CREATE DATABASE pokeapi');
      print("Base de datos 'pokeapi' creada exitosamente");
    } catch (e) {
      print("⚠️Error creando base de datos: $e");
      rethrow;
    }
  }

  static Future<void> cargarEstructuraDeDatos(MySqlConnection conn) async {
    try {
      await conn.query('USE pokeapi');

      await conn.query('''
        CREATE TABLE caja_pokemons (
          id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
          usuario_id INT(11) NOT NULL,
          pokemon_id INT(11) NOT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
      ''');

      await conn.query('''
        CREATE TABLE configuracion_exp (
          nivel INT(11) NOT NULL PRIMARY KEY,
          exp_requerida INT(11) DEFAULT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
      ''');

      await conn.query('''
        INSERT INTO configuracion_exp (nivel, exp_requerida) VALUES
          (1, 100),
          (2, 200),
          (3, 300),
          (4, 400),
          (5, 500),
          (6, 600),
          (7, 700),
          (8, 800),
          (9, 900),
          (10, 1000)
      ''');

      await conn.query('''
        CREATE TABLE inventario_pokemons (
          id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
          usuario_id INT(11) NOT NULL,
          pokemon_id INT(11) NOT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
      ''');

      await conn.query('''
        CREATE TABLE rutas (
          id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
          nombre VARCHAR(255) DEFAULT NULL,
          nivel_minimo INT(11) DEFAULT NULL,
          pokemon_ids VARCHAR(255) DEFAULT NULL,
          probabilidad_captura INT(3) NOT NULL DEFAULT 0
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
      ''');

      await conn.query('''
        CREATE TABLE usuarios (
          id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
          username VARCHAR(255) NOT NULL,
          password VARCHAR(255) NOT NULL,
          nivel INT(11) NOT NULL DEFAULT 1,
          exp_actual INT(11) DEFAULT 0
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
      ''');

      await conn.query('''
        CREATE TABLE usuario_activo (
          usuario_id INT(11) NOT NULL,
          pokemon_id INT(11) NOT NULL,
          PRIMARY KEY (usuario_id, pokemon_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
      ''');

      await conn.query('''
        INSERT INTO `rutas` (`id`, `nombre`, `nivel_minimo`, `pokemon_ids`, `probabilidad_captura`) VALUES
          (1, '⛺ Pradera soleada', 1, '16,19,10,11,13,14,29,32,46', 50),
          (2, '🌳 Bosque frondoso', 2, '10 10,11,12,13,14,15,16,43,46,69,92', 35),
          (3, '🗻 Monte Rocoso', 3, '81,50,37,35,56,66,74,75,84,95', 30),
          (4, '🌋 Volcán del desierto', 4, '322,229,631,776,556,328,551,450,443', 30),
          (5, '🏭 Central eléctrica abandonada', 5, '81,100,88,599,595,479,568,624', 40),
          (6, '🛕 Ruinas antiguas', 6, '201,343,622,562,561,605,436', 25),
          (7, '🌊 Mar tranquilo', 7, '456,170,90,116,366,458,592,223', 60),
          (8, '🕌 Templo del valle', 8, '147,443,610,371,714,333,328,633,696', 15),
          (9, '🏡 Guardería', 9, '172,173,174,175,298,406,439,446,447,239', 10),
          (10, '🕋 Dimensión extraña', 10, '151,249,250,384,487,646,718,788,251,485', 1);
      ''');

      print("✅Estructura de datos cargada exitosamente✅");
    } catch (e) {
      print("⚠️Error cargando estructura de datos: $e");
      rethrow;
    }
  }
}