
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:prueba_flutter/features/challenges/models/desafio_museo.dart';

class DesafioService {
  final SupabaseClient supabase;

  DesafioService(this.supabase);




  // Listar desafíos de una misión
  Future<List<DesafioMuseo>> listarPorMision(
      String idMision, {
        bool soloActivos = false,
      }) async {
    var query = supabase
        .from('desafios')
        .select()
        .eq('id_mision', idMision);

    if (soloActivos) {
      query = query.eq('estado', true);
    }

    final data = await query.order('orden');

    return (data as List)
        .map((item) => DesafioMuseo.fromMap(
      Map<String, dynamic>.from(item),
    ))
        .toList();
  }

  Future<List<DesafioMuseo>> listarPreguntasPorMision(
      String idMision,
      ) async {
    final desafios = await listarPorMision(
      idMision,
      soloActivos: true,
    );

    return desafios
        .where((desafio) => desafio.tipo == TipoDesafio.pregunta)
        .toList();
  }





  // Listar todos los desafíos
  Future<List<DesafioMuseo>> listarTodos() async {
    final data = await supabase
        .from('desafios')
        .select()
        .order('id_mision')
        .order('orden');

    return (data as List)
        .map((item) => DesafioMuseo.fromMap(
      Map<String, dynamic>.from(item),
    ))
        .toList();
  }

  // Obtener desafío por ID
  Future<DesafioMuseo?> obtenerPorId(String id) async {
    final data = await supabase
        .from('desafios')
        .select()
        .eq('id_desafio', id)
        .maybeSingle();

    if (data == null) return null;

    return DesafioMuseo.fromMap(data);
  }

  // Crear desafío
  Future<String> crear(DesafioMuseo desafio) async {
    final datos = desafio.toMap();

    // El UUID lo genera PostgreSQL.
    datos.remove('id_desafio');

    final resultado = await supabase
        .from('desafios')
        .insert(datos)
        .select('id_desafio')
        .single();

    return resultado['id_desafio'] as String;
  }

  // Actualizar desafío
  Future<void> actualizar(DesafioMuseo desafio) async {
    await supabase
        .from('desafios')
        .update(desafio.toMap())
        .eq('id_desafio', desafio.idDesafio);
  }

  // Cambiar estado
  Future<void> cambiarEstado(
      String idDesafio,
      bool nuevoEstado,
      ) async {
    await supabase
        .from('desafios')
        .update({'estado': nuevoEstado})
        .eq('id_desafio', idDesafio);
  }

  // Eliminar desafío
  Future<void> eliminar(String idDesafio) async {
    await supabase
        .from('desafios')
        .delete()
        .eq('id_desafio', idDesafio);
  }

  // Listar misiones para el selector administrativo
  Future<List<Map<String, dynamic>>> listarMisiones() async {
    final data = await supabase
        .from('misiones')
        .select('id_mision, nombre')
        .order('nombre');

    return (data as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
