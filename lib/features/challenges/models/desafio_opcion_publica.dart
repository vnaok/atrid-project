class DesafioOpcionPublica {
  final String idOpcion;
  final String idDesafio;
  final String texto;
  final String? imagen;
  final int orden;

  const DesafioOpcionPublica({
    required this.idOpcion,
    required this.idDesafio,
    required this.texto,
    this.imagen,
    required this.orden,
  });

  factory DesafioOpcionPublica.fromMap(
      Map<String, dynamic> map,
      ) {
    return DesafioOpcionPublica(
      idOpcion: map['id_opcion'].toString(),
      idDesafio: map['id_desafio'].toString(),
      texto: map['texto'] as String? ?? '',
      imagen: map['imagen'] as String?,
      orden: (map['orden'] as num?)?.toInt() ?? 1,
    );
  }
}