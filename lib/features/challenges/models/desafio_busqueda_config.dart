
class DesafioBusquedaConfig {
  final String idDesafio;
  final String descripcionReferencia;
  final List<String> etiquetasEsperadas;
  final double umbralConfianza;

  const DesafioBusquedaConfig({
    required this.idDesafio,
    required this.descripcionReferencia,
    required this.etiquetasEsperadas,
    required this.umbralConfianza,
  });

  factory DesafioBusquedaConfig.fromMap(
      Map<String, dynamic> map,
      ) {
    return DesafioBusquedaConfig(
      idDesafio: map['id_desafio'].toString(),
      descripcionReferencia:
      map['descripcion_referencia'] ?? '',
      etiquetasEsperadas:
      List<String>.from(map['etiquetas_esperadas'] ?? []),
      umbralConfianza:
      (map['umbral_confianza'] as num?)?.toDouble() ?? 0.75,
    );
  }
}
