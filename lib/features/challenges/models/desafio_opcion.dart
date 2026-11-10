
class DesafioOpcion {
  final String idOpcion;
  final String idDesafio;
  final String texto;
  final String? imagen;
  final bool esCorrecta;
  final int orden;

  const DesafioOpcion({
    required this.idOpcion,
    required this.idDesafio,
    required this.texto,
    this.imagen,
    required this.esCorrecta,
    required this.orden,
  });

  factory DesafioOpcion.fromMap(Map<String, dynamic> map) {
    return DesafioOpcion(
      idOpcion: map['id_opcion'].toString(),
      idDesafio: map['id_desafio'].toString(),
      texto: map['texto'] as String? ?? '',
      imagen: map['imagen'] as String?,
      esCorrecta: map['es_correcta'] as bool? ?? false,
      orden: (map['orden'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_desafio': idDesafio,
      'texto': texto,
      'imagen': imagen,
      'es_correcta': esCorrecta,
      'orden': orden,
    };
  }
}
