import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/badge.dart';
import 'dart:typed_data';
class BadgeService {
  final SupabaseClient supabase;

  BadgeService(this.supabase);
// cli_ariel@ArielV_1794913937
  // ==========================================
  // LISTAR INSIGNIAS ACTIVAS DE UN MUSEO
  // ==========================================

  Future<List<Badge>> listarPorMuseo(
      String idMuseo, {
        bool soloActivas = true,
      }) async {
    var query = supabase
        .from('insignias')
        .select()
        .eq('id_museo', idMuseo);

    if (soloActivas) {
      query = query.eq('estado', true);
    }

    final response = await query
        .order('puntos_requeridos', ascending: true);

    return response
        .map<Badge>((item) => Badge.fromMap(item))
        .toList();
  }

  // ==========================================
  // OBTENER UNA INSIGNIA POR ID
  // ==========================================

  Future<Badge?> obtenerPorId(String idInsignia) async {
    final response = await supabase
        .from('insignias')
        .select()
        .eq('id_insignia', idInsignia)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Badge.fromMap(response);
  }


  Future<String> subirImagen({
    required String idMuseo,
    required Uint8List bytes,
    required String extension,
  }) async {
    final ext = extension.toLowerCase();

    final contentType = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => throw Exception('Formato de imagen no permitido'),
    };

    final nombreArchivo =
        '${DateTime.now().microsecondsSinceEpoch}.$ext';

    final ruta = '$idMuseo/$nombreArchivo';

    await supabase.storage
        .from('insignias-museo')
        .uploadBinary(
      ruta,
      bytes,
      fileOptions: FileOptions(
        contentType: contentType,
        upsert: false,
      ),
    );

    return ruta;
  }

  Future<void> eliminarImagen(String ruta) async {
    await supabase.storage
        .from('insignias-museo')
        .remove([ruta]);
  }
  String? obtenerImagenUrl(String? ruta) {
    if (ruta == null || ruta.trim().isEmpty) {
      return null;
    }

    return supabase.storage
        .from('insignias-museo')
        .getPublicUrl(ruta);
  }

  // ==========================================
  // CREAR INSIGNIA
  // ==========================================

  Future<void> crear(Badge badge) async {
    await supabase.from('insignias').insert({
      'id_museo': badge.idMuseo,
      'nombre': badge.nombre,
      'descripcion': badge.descripcion,
      'imagen': badge.imagen,
      'condicion': badge.condicion,
      'puntos_requeridos': badge.puntosRequeridos,
      'estado': badge.estado,
    });
  }

  // ==========================================
  // ACTUALIZAR INSIGNIA
  // ==========================================

  Future<void> actualizar(Badge badge) async {
    await supabase
        .from('insignias')
        .update({
      'nombre': badge.nombre,
      'descripcion': badge.descripcion,
      'imagen': badge.imagen,
      'condicion': badge.condicion,
      'puntos_requeridos': badge.puntosRequeridos,
      'estado': badge.estado,
    })
        .eq('id_insignia', badge.idInsignia);
  }



  // ==========================================
  // ELIMINAR INSIGNIA
  // ==========================================

  Future<void> eliminar(String idInsignia) async {
    await supabase
        .from('insignias')
        .delete()
        .eq('id_insignia', idInsignia);
  }

  // ==========================================
  // CAMBIAR ESTADO
  // ==========================================

  Future<void> cambiarEstado(
      String idInsignia,
      bool nuevoEstado,
      ) async {
    await supabase
        .from('insignias')
        .update({
      'estado': nuevoEstado,
    })
        .eq('id_insignia', idInsignia);
  }
}