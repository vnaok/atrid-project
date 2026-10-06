class ObjetoMuseo {
  final String id;
  final String nombre;
  final String descripcion;
  final String? informacion_historica;
  final String? imagen;
  final String? ubicacion;

  ObjetoMuseo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.informacion_historica,
    this.imagen,
    this.ubicacion,
  });

  factory ObjetoMuseo.fromMap(Map<String, dynamic> map) {
    return ObjetoMuseo(
      id: map['id_objeto'],
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      informacion_historica: map['informacion_historica'],
      imagen: map['imagen'],
      ubicacion: map['ubicacion'],
    );
  }
}