import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/Mision.dart';
import '../model/ObjetoMuseo.dart';
import '../model/VisitorState.dart';

class TuristaService {
  final SupabaseClient supabase;

  TuristaService(this.supabase);

  // =========================================================
  // MISIONES
  // =========================================================

  Future<List<Mision>> obtenerMisiones(String museoId) async {
    final data = await supabase
        .from('misiones')
        .select()
        .eq('id_museo', museoId)
        .eq('estado', 'publicada')
        .order('nombre');

    return data
        .map<Mision>((json) => Mision.fromMap(json))
        .toList();
  }

  // =========================================================
  // OBJETOS
  // =========================================================

  Future<List<ObjetoMuseo>> obtenerObjetos(String museoId) async {
    final response = await supabase
        .from('objetos')
        .select();

    print('TODOS LOS OBJETOS SUPABASE: $response');
    print('MUSEO BUSCADO: $museoId');

    return (response as List)
        .map((item) => ObjetoMuseo.fromMap(item))
        .toList();
  }

  // =========================================================
  // ESTADISTICAS
  // =========================================================

  Future<VisitorState> obtenerEstadisticas(String museoId) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return VisitorState(
        misionesCompletadas: 0,
        puntos: 0,
      );
    }

    return VisitorState(
      misionesCompletadas: 0,
      puntos: 0,
    );
  }
}