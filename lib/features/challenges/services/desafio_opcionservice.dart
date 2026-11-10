
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/desafio_opcion.dart';

class DesafioOpcionService {
  final SupabaseClient supabase;

  DesafioOpcionService(this.supabase);

  // Listar opciones de un desafío
  Future<List<DesafioOpcion>> listarPorDesafio(
      String idDesafio,
      ) async {
    final data = await supabase
        .from('desafio_opciones')
        .select()
        .eq('id_desafio', idDesafio)
        .order('orden');

    return (data as List)
        .map((item) => DesafioOpcion.fromMap(
      Map<String, dynamic>.from(item),
    ))
        .toList();
  }

  // Crear opción
  Future<void> crear(DesafioOpcion opcion) async {
    await supabase
        .from('desafio_opciones')
        .insert(opcion.toMap());
  }

  // Crear múltiples opciones
  Future<void> crearVarias(
      List<DesafioOpcion> opciones,
      ) async {
    if (opciones.isEmpty) return;

    await supabase
        .from('desafio_opciones')
        .insert(
      opciones.map((opcion) => opcion.toMap()).toList(),
    );
  }

  // Actualizar opción
  Future<void> actualizar(DesafioOpcion opcion) async {
    await supabase
        .from('desafio_opciones')
        .update(opcion.toMap())
        .eq('id_opcion', opcion.idOpcion);
  }

  // Eliminar opción
  Future<void> eliminar(String idOpcion) async {
    await supabase
        .from('desafio_opciones')
        .delete()
        .eq('id_opcion', idOpcion);
  }

  // Eliminar todas las opciones de un desafío
  Future<void> eliminarPorDesafio(
      String idDesafio,
      ) async {
    await supabase
        .from('desafio_opciones')
        .delete()
        .eq('id_desafio', idDesafio);
  }
}
