import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/badge_earned.dart';

class BadgeEarnedService {
  final SupabaseClient supabase;

  BadgeEarnedService(this.supabase);

  // ==========================================
  // LISTAR INSIGNIAS OBTENIDAS POR VISITA
  // ==========================================

  Future<List<BadgeEarned>> listarPorVisita(
      String idVisita,
      ) async {
    final response = await supabase
        .from('insignias_obtenidas')
        .select()
        .eq('id_visita', idVisita)
        .order('fecha_obtencion', ascending: false);

    return response
        .map<BadgeEarned>(
          (item) => BadgeEarned.fromMap(item),
    )
        .toList();
  }

  // ==========================================
  // OBTENER UNA INSIGNIA OBTENIDA
  // ==========================================

  Future<BadgeEarned?> obtenerPorId(
      String idInsigniaObtenida,
      ) async {
    final response = await supabase
        .from('insignias_obtenidas')
        .select()
        .eq(
      'id_insignia_obtenida',
      idInsigniaObtenida,
    )
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return BadgeEarned.fromMap(response);
  }

  // ==========================================
  // VERIFICAR SI UNA VISITA YA OBTUVO UNA INSIGNIA
  // ==========================================

  Future<bool> yaObtenida(
      String idVisita,
      String idInsignia,
      ) async {
    final response = await supabase
        .from('insignias_obtenidas')
        .select('id_insignia_obtenida')
        .eq('id_visita', idVisita)
        .eq('id_insignia', idInsignia)
        .maybeSingle();

    return response != null;
  }

  // ==========================================
  // CONTAR INSIGNIAS OBTENIDAS
  // ==========================================

  Future<int> contarPorVisita(String idVisita) async {
    final response = await supabase
        .from('insignias_obtenidas')
        .select('id_insignia_obtenida')
        .eq('id_visita', idVisita)
        .count(CountOption.exact);

    return response.count;
  }
}