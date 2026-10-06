import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/Mission.dart';

class MissionService {
  final SupabaseClient supabase;

  MissionService(this.supabase);

  // ============================================================
  // LISTAR MISIONES
  // ============================================================

  Future<List<Mission>> obtenerMisiones(String museoId) async {
    final data = await supabase
        .from('misiones')
        .select()
        .eq('id_museo', museoId)
        .order('fecha_creacion', ascending: false);

    return (data as List)
        .map((map) => Mission.fromMap(map))
        .toList();
  }

  // ============================================================
  // OBTENER UNA MISION
  // ============================================================

  Future<Mission?> obtenerMision(String idMision) async {
    final data = await supabase
        .from('misiones')
        .select()
        .eq('id_mision', idMision)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return Mission.fromMap(data);
  }

  // ============================================================
  // CREAR MISION
  // ============================================================

  Future<Mission> crearMision({
    required String museoId,
    required String nombre,
    String? descripcion,
    String? imagen,
    int? duracionEstimada,
    required String dificultad,
    String estado = 'borrador',
  }) async {
    final data = await supabase
        .from('misiones')
        .insert({
      'id_museo': museoId,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen': imagen,
      'duracion_estimada': duracionEstimada,
      'dificultad': dificultad,
      'estado': estado,
    })
        .select()
        .single();

    return Mission.fromMap(data);
  }

  // ============================================================
  // MODIFICAR MISION
  // ============================================================

  Future<Mission> actualizarMision({
    required String idMision,
    required String nombre,
    String? descripcion,
    String? imagen,
    int? duracionEstimada,
    required String dificultad,
    required String estado,
  }) async {
    final data = await supabase
        .from('misiones')
        .update({
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen': imagen,
      'duracion_estimada': duracionEstimada,
      'dificultad': dificultad,
      'estado': estado,
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    })
        .eq('id_mision', idMision)
        .select()
        .single();

    return Mission.fromMap(data);
  }

  // ============================================================
  // ELIMINAR MISION
  // ============================================================

  Future<void> eliminarMision(String idMision) async {
    await supabase
        .from('misiones')
        .delete()
        .eq('id_mision', idMision);
  }
}