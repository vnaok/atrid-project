class Mision {
  final String id;
  final String nombre;
  final String descripcion;
  final int? duracionEstimada;
  final String? imagen;
  final String? dificultad;

  Mision({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.duracionEstimada,
    this.imagen,
    this.dificultad,
  });

  factory Mision.fromMap(Map<String, dynamic> map) {
    return Mision(
      id: map['id_mision'],
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      duracionEstimada: map['duracion_estimada'],
      imagen: map['imagen'],
      dificultad: map['dificultad'],
    );
  }
}