class Object {
  final String idObjeto;
  final String idMuseo;
  final String nombre;
  final String? descripcion;
  final String? informacionHistorica;
  final String? imagen;
  final String codigoIdentificador;
  final String? ubicacion;
  final bool estado;

  Object({
    required this.idObjeto,
    required this.idMuseo,
    required this.nombre,
    this.descripcion,
    this.informacionHistorica,
    this.imagen,
    required this.codigoIdentificador,
    this.ubicacion,
    required this.estado,
  });

  factory Object.fromMap(Map<String, dynamic> map) {
    return Object(
      idObjeto: map['id_objeto'] as String,
      idMuseo: map['id_museo'] as String,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      informacionHistorica: map['informacion_historica'] as String?,
      imagen: map['imagen'] as String?,
      codigoIdentificador: map['codigo_identificador'] as String,
      ubicacion: map['ubicacion'] as String?,
      estado: map['estado'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_objeto': idObjeto,
      'id_museo': idMuseo,
      'nombre': nombre,
      'descripcion': descripcion,
      'informacion_historica': informacionHistorica,
      'imagen': imagen,
      'codigo_identificador': codigoIdentificador,
      'ubicacion': ubicacion,
      'estado': estado,
    };
  }
}