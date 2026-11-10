enum TipoDesafio {
  pregunta,
  busquedaObjeto,
  escaneoQr,
  identificacion,
}

extension TipoDesafioExtension on TipoDesafio {
  String get valorBD {
    switch (this) {
      case TipoDesafio.pregunta:
        return 'pregunta';
      case TipoDesafio.busquedaObjeto:
        return 'busqueda_objeto';
      case TipoDesafio.escaneoQr:
        return 'escaneo_qr';
      case TipoDesafio.identificacion:
        return 'identificacion';
    }
  }

  String get etiqueta {
    switch (this) {
      case TipoDesafio.pregunta:
        return 'Pregunta';
      case TipoDesafio.busquedaObjeto:
        return 'Búsqueda de objeto';
      case TipoDesafio.escaneoQr:
        return 'Escaneo QR';
      case TipoDesafio.identificacion:
        return 'Identificación';
    }
  }

  static TipoDesafio desdeBD(String valor) {
    return TipoDesafio.values.firstWhere(
          (tipo) => tipo.valorBD == valor,
      orElse: () => throw FormatException(
        'Tipo de desafío desconocido: $valor',
      ),
    );
  }
}


class DesafioMuseo {
  final String idDesafio;
  final String idMision;
  final String titulo;
  final String descripcion;
  final TipoDesafio tipo;
  final int orden;
  final int puntos;
  final int cantidadMaxIntentos;
  final bool permitirReintento;
  final bool estado;

  const DesafioMuseo({
    required this.idDesafio,
    required this.idMision,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.orden,
    required this.puntos,
    required this.cantidadMaxIntentos,
    required this.permitirReintento,
    required this.estado,
  });

  factory DesafioMuseo.fromMap(Map<String, dynamic> map) {
    return DesafioMuseo(
      idDesafio: map['id_desafio'].toString(),
      idMision: map['id_mision'].toString(),
      titulo: map['titulo'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      tipo: TipoDesafioExtension.desdeBD(
        map['tipo'] as String,
      ),
      orden: (map['orden'] as num?)?.toInt() ?? 1,
      puntos: (map['puntos'] as num?)?.toInt() ?? 0,
      cantidadMaxIntentos:
      (map['cantidad_max_intentos'] as num?)?.toInt() ?? 3,
      permitirReintento:
      map['permitir_reintento'] as bool? ?? true,
      estado: map['estado'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_mision': idMision,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo.valorBD,
      'orden': orden,
      'puntos': puntos,
      'cantidad_max_intentos': cantidadMaxIntentos,
      'permitir_reintento': permitirReintento,
      'estado': estado,
    };
  }

  DesafioMuseo copyWith({
    String? idDesafio,
    String? idMision,
    String? titulo,
    String? descripcion,
    TipoDesafio? tipo,
    int? orden,
    int? puntos,
    int? cantidadMaxIntentos,
    bool? permitirReintento,
    bool? estado,
  }) {
    return DesafioMuseo(
      idDesafio: idDesafio ?? this.idDesafio,
      idMision: idMision ?? this.idMision,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      orden: orden ?? this.orden,
      puntos: puntos ?? this.puntos,
      cantidadMaxIntentos:
      cantidadMaxIntentos ?? this.cantidadMaxIntentos,
      permitirReintento:
      permitirReintento ?? this.permitirReintento,
      estado: estado ?? this.estado,
    );
  }
}
