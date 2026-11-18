class Badge {
  final String idInsignia;
  final String? idMuseo;
  final String nombre;
  final String? descripcion;
  final String? imagen;
  final String? condicion;
  final int puntosRequeridos;
  final bool estado;

  Badge({
    required this.idInsignia,
    this.idMuseo,
    required this.nombre,
    this.descripcion,
    this.imagen,
    this.condicion,
    required this.puntosRequeridos,
    required this.estado,
  });

  // ==========================================
  // FROM MAP
  // ==========================================

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      idInsignia: map['id_insignia'],
      idMuseo: map['id_museo'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      imagen: map['imagen'],
      condicion: map['condicion'],
      puntosRequeridos: map['puntos_requeridos'] ?? 0,
      estado: map['estado'] ?? true,
    );
  }

  // ==========================================
  // TO MAP
  // ==========================================

  Map<String, dynamic> toMap() {
    return {
      'id_insignia': idInsignia,
      'id_museo': idMuseo,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen': imagen,
      'condicion': condicion,
      'puntos_requeridos': puntosRequeridos,
      'estado': estado,
    };
  }
}