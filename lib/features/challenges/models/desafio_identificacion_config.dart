
class DesafioIdentificacionConfig {
  final String idDesafio;
  final String? idObjetoCorrecto;
  final String? imagenReferencia;
  final String tipoIdentificacion;

  const DesafioIdentificacionConfig({
    required this.idDesafio,
    this.idObjetoCorrecto,
    this.imagenReferencia,
    required this.tipoIdentificacion,
  });

  factory DesafioIdentificacionConfig.fromMap(
      Map<String, dynamic> map,
      ) {
    return DesafioIdentificacionConfig(
      idDesafio: map['id_desafio'].toString(),
      idObjetoCorrecto: map['id_objeto_correcto']?.toString(),
      imagenReferencia: map['imagen_referencia'] as String?,
      tipoIdentificacion:
      map['tipo_identificacion'] as String,
    );
  }
}
