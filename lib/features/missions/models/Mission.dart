class Mission {
  final String idMision;
  final String idMuseo;
  final String nombre;
  final String? descripcion;
  final String? imagen;
  final int? duracionEstimada;
  final String dificultad;
  final String estado;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  Mission({
    required this.idMision,
    required this.idMuseo,
    required this.nombre,
    this.descripcion,
    this.imagen,
    this.duracionEstimada,
    required this.dificultad,
    required this.estado,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory Mission.fromMap(Map<String, dynamic> map) {
    return Mission(
      idMision: map['id_mision'] as String,
      idMuseo: map['id_museo'] as String,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      imagen: map['imagen'] as String?,
      duracionEstimada: map['duracion_estimada'] as int?,
      dificultad: map['dificultad'] as String,
      estado: map['estado'] as String,
      fechaCreacion: DateTime.parse(
        map['fecha_creacion'].toString(),
      ),
      fechaActualizacion: DateTime.parse(
        map['fecha_actualizacion'].toString(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_mision': idMision,
      'id_museo': idMuseo,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen': imagen,
      'duracion_estimada': duracionEstimada,
      'dificultad': dificultad,
      'estado': estado,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }
}