import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  final SupabaseClient supabase;

  AnalyticsService(this.supabase);

  // ==========================================
  // CONTAR MISIONES TOTALES
  // ==========================================

  Future<int> contarMisionesTotales(String idMuseo) async {
    final response = await supabase
        .from('misiones')
        .select()
        .eq('id_museo', idMuseo)
        .count(CountOption.exact);

    return response.count;
  }

  // ==========================================
  // CONTAR INSIGNIAS
  // ==========================================

  Future<int> contarInsignias(String idMuseo) async {
    final response = await supabase
        .from('insignias')
        .select()
        .eq('id_museo', idMuseo)
        .count(CountOption.exact);

    return response.count;
  }

  // ==========================================
  // CONTAR OBJETOS
  // ==========================================


  Future<List<Map<String, dynamic>>> obtenerIniciosUltimos7Dias(
      String idMuseo,
      ) async {
    final ahora = DateTime.now();

    // Incluimos hoy y los seis días anteriores.
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fechaDesde = hoy.subtract(const Duration(days: 6));
    final fechaHasta = hoy.add(const Duration(days: 1));

    final response = await supabase
        .from('visitas_museo')
        .select('fecha_inicio')
        .eq('id_museo', idMuseo)
        .gte(
      'fecha_inicio',
      fechaDesde.toUtc().toIso8601String(),
    )
        .lt(
      'fecha_inicio',
      fechaHasta.toUtc().toIso8601String(),
    )
        .order('fecha_inicio');

    // Inicializar los siete días en cero.
    final Map<String, int> conteos = {};

    for (int i = 0; i < 7; i++) {
      final fecha = fechaDesde.add(Duration(days: i));
      final clave = _formatearFecha(fecha);

      conteos[clave] = 0;
    }

    // Contar visitas por día.
    for (final visita in response) {
      final fecha = DateTime.parse(
        visita['fecha_inicio'],
      ).toLocal();

      final clave = _formatearFecha(
        DateTime(fecha.year, fecha.month, fecha.day),
      );

      if (conteos.containsKey(clave)) {
        conteos[clave] = conteos[clave]! + 1;
      }
    }

    return conteos.entries.map((entry) {
      return {
        'fecha': entry.key,
        'cantidad': entry.value,
      };
    }).toList();
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.year}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
  }

  Future<int> contarObjetos(String idMuseo) async {
    final response = await supabase
        .from('objetos')
        .select()
        .eq('id_museo', idMuseo)
        .count(CountOption.exact);

    return response.count;
  }

  // ==========================================
  // CONTAR CUENTAS CREADAS
  // ==========================================

  Future<int> contarCuentasCreadas() async {
    final response = await supabase
        .from('perfiles')
        .select()
        .count(CountOption.exact);

    return response.count;
  }
}