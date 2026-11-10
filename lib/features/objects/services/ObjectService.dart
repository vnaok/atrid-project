import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/Object.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class ObjetoService {
  final SupabaseClient supabase;

  ObjetoService(this.supabase);

  // ==========================================
  // LISTAR OBJETOS DE UN MUSEO
  // ==========================================

  Future<List<Object>> obtenerObjetos(String museoId) async {
    final data = await supabase
        .from('objetos')
        .select()
        .eq('id_museo', museoId)
        .order('nombre', ascending: true);

    return (data as List)
        .map((map) => Object.fromMap(map))
        .toList();
  }

  // ==========================================
  // OBTENER UN OBJETO
  // ==========================================

  Future<Object?> obtenerObjeto(String idObjeto) async {
    final data = await supabase
        .from('objetos')
        .select()
        .eq('id_objeto', idObjeto)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return Object.fromMap(data);
  }

  // ==========================================
  // CREAR OBJETO
  // ==========================================

  Future<Object> crearObjeto({
    required String museoId,
    required String nombre,
    String? descripcion,
    String? informacionHistorica,
    String? imagen,
    required String codigoIdentificador,
    String? ubicacion,
    bool estado = true,
  }) async {
    final data = await supabase
        .from('objetos')
        .insert({
      'id_museo': museoId,
      'nombre': nombre,
      'descripcion': descripcion,
      'informacion_historica': informacionHistorica,
      'imagen': imagen,
      'codigo_identificador': codigoIdentificador,
      'ubicacion': ubicacion,
      'estado': estado,
    })
        .select()
        .single();

    return Object.fromMap(data);
  }

  // ==========================================
  // MODIFICAR OBJETO
  // ==========================================

  Future<Object> actualizarObjeto({
    required String idObjeto,
    required String nombre,
    String? descripcion,
    String? informacionHistorica,
    String? imagen,
    required String codigoIdentificador,
    String? ubicacion,
    required bool estado,
  }) async {
    final data = await supabase
        .from('objetos')
        .update({
      'nombre': nombre,
      'descripcion': descripcion,
      'informacion_historica': informacionHistorica,
      'imagen': imagen,
      'codigo_identificador': codigoIdentificador,
      'ubicacion': ubicacion,
      'estado': estado,
    })
        .eq('id_objeto', idObjeto)
        .select()
        .single();

    return Object.fromMap(data);
  }

  // ==========================================
  // ELIMINAR OBJETO
  // ==========================================

  Future<void> eliminarObjeto(String idObjeto) async {
    await supabase
        .from('objetos')
        .delete()
        .eq('id_objeto', idObjeto);
  }

  // ==========================================
// SUBIR IMAGEN A SUPABASE STORAGE
// ==========================================

  Future<String> subirImagen({
    required String museoId,
    required File imagen,
  }) async {
    final extension = p.extension(imagen.path).toLowerCase();

    final nombreArchivo =
        '${DateTime.now().microsecondsSinceEpoch}$extension';

    final ruta =
        '$museoId/objetos/$nombreArchivo';

    final contentType = switch (extension) {
      '.png' => 'image/png',
      '.webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    await supabase.storage
        .from('objetos-museo')
        .upload(
      ruta,
      imagen,
      fileOptions: FileOptions(
        contentType: contentType,
        upsert: false,
      ),
    );

    return ruta;
  }
}