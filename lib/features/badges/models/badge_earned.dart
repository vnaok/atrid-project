class BadgeEarned {
  final String idInsigniaObtenida;
  final String idInsignia;
  final String idVisita;
  final DateTime fechaObtencion;

  BadgeEarned({
    required this.idInsigniaObtenida,
    required this.idInsignia,
    required this.idVisita,
    required this.fechaObtencion,
  });

  // ==========================================
  // FROM MAP
  // ==========================================

  factory BadgeEarned.fromMap(Map<String, dynamic> map) {
    return BadgeEarned(
      idInsigniaObtenida: map['id_insignia_obtenida'],
      idInsignia: map['id_insignia'],
      idVisita: map['id_visita'],
      fechaObtencion: DateTime.parse(
        map['fecha_obtencion'],
      ),
    );
  }

  // ==========================================
  // TO MAP
  // ==========================================

  Map<String, dynamic> toMap() {
    return {
      'id_insignia_obtenida': idInsigniaObtenida,
      'id_insignia': idInsignia,
      'id_visita': idVisita,
      'fecha_obtencion': fechaObtencion.toIso8601String(),
    };
  }
}