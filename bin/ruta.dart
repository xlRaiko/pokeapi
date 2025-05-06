class Ruta {
  final int id;
  final String nombre;
  final int nivelMinimo;
  final List<int> pokemonIds;
  final int probabilidadCaptura;

  Ruta({
    required this.id,
    required this.nombre,
    required this.nivelMinimo,
    required this.pokemonIds,
    required this.probabilidadCaptura,
  });
}