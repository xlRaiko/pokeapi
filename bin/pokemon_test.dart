import 'dart:io';

class TestPersonalidadPokemon {
  final List<Map<String, dynamic>> preguntas = [
    {
      'pregunta': '¿Ves a alguien caer al suelo? ¿Qué haces?',
      'opciones': {
        'a': {'texto': 'Corro a ayudarle.🙌', 'valiente': 2},
        'b': {'texto': 'Espero que alguien más lo ayude.🙎', 'tímido': 2},
        'c': {'texto': 'Me río un poco, pero luego ayudo.😁', 'divertido': 2},
      }
    },
    {
      'pregunta': 'Te encuentras un billete en el suelo. ¿Qué haces?',
      'opciones': {
        'a': {'texto': 'Lo entrego a la policía.👮', 'honesto': 2},
        'b': {'texto': 'Lo guardo sin dudar.📥', 'atrevido': 2},
        'c': {'texto': 'Lo dejo ahí, no es mío.🙅', 'tranquilo': 2},
      }
    },
    {
      'pregunta': '¿Te consideras una persona sociable?',
      'opciones': {
        'a': {'texto': 'Muchísimo.✌', 'amistoso': 2},
        'b': {'texto': 'Solo con gente de confianza.🤏', 'tímido': 2},
        'c': {'texto': 'Prefiero estar solo.👎', 'tranquilo': 2},
      }
    },
  ];

  final Map<String, int> rasgos = {
    'valiente': 0,
    'tímido': 0,
    'divertido': 0,
    'honesto': 0,
    'atrevido': 0,
    'tranquilo': 0,
    'amistoso': 0,
  };

  final Map<String, String> pokemones = {
    'valiente': 'Charmander',
    'tímido': 'Mudkip',
    'divertido': 'Psyduck',
    'honesto': 'Bulbasaur',
    'atrevido': 'Torchic',
    'tranquilo': 'Squirtle',
    'amistoso': 'Pikachu',
  };

void iniciar() {
  stdout.writeln();
  stdout.writeln('\n📜¡Bienvenido al test de personalidad sobre qué pokemon se asocia más a ti!📜\n');

  for (var pregunta in preguntas) {
    stdout.writeln(pregunta['pregunta']);
    final opciones = pregunta['opciones'] as Map<String, dynamic>;
    opciones.forEach((clave, valor) {
      stdout.writeln('  $clave) ${valor['texto']}');
    });

    String? respuesta;
    do {
      stdout.write('Tu respuesta (elige ${opciones.keys.join(", ")}): ');
      respuesta = stdin.readLineSync()?.toLowerCase();
      if (respuesta == null || !opciones.containsKey(respuesta)) {
        stdout.writeln('⚠️Respuesta inválida. Por favor elige una opción válida.\n');
      }
    } while (respuesta == null || !opciones.containsKey(respuesta));

    final rasgosSeleccionados = opciones[respuesta] as Map<String, dynamic>;
    rasgosSeleccionados.forEach((clave, valor) {
      if (clave != 'texto' && rasgos.containsKey(clave) && valor is int) {
        rasgos[clave] = rasgos[clave]! + valor;
      }
    });

    stdout.writeln('');
  }

  final resultado = obtenerRasgoDominante();
  stdout.writeln('📌¡Tu Pokémon inicial es: ${pokemones[resultado]}!📌');
}

  String obtenerRasgoDominante() {
    return rasgos.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}