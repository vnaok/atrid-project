class DesafioQrConfig {
  final String idDesafio;
  final String idQr;
  final String? pista;

  const DesafioQrConfig({
    required this.idDesafio,
    required this.idQr,
    this.pista,
  });

  factory DesafioQrConfig.fromMap(Map<String, dynamic> map) {
    return DesafioQrConfig(
      idDesafio: map['id_desafio'].toString(),
      idQr: map['id_qr'].toString(),
      pista: map['pista'] as String?,
    );
  }
}