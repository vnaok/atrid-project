
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/desafio_qr_config.dart';

class DesafioQrService {
  final SupabaseClient supabase;

  DesafioQrService(this.supabase);

  // Obtener configuración QR
  Future<DesafioQrConfig?> obtenerConfiguracion(
      String idDesafio,
      ) async {
    final data = await supabase
        .from('desafio_qr_config')
        .select()
        .eq('id_desafio', idDesafio)
        .maybeSingle();

    if (data == null) return null;

    return DesafioQrConfig.fromMap(data);
  }

  // Crear configuración QR
  Future<void> crearConfiguracion(
      DesafioQrConfig config,
      ) async {
    await supabase
        .from('desafio_qr_config')
        .insert({
      'id_desafio': config.idDesafio,
      'id_qr': config.idQr,
      'pista': config.pista,
    });
  }

  // Actualizar configuración QR
  Future<void> actualizarConfiguracion(
      DesafioQrConfig config,
      ) async {
    await supabase
        .from('desafio_qr_config')
        .update({
      'id_qr': config.idQr,
      'pista': config.pista,
    })
        .eq('id_desafio', config.idDesafio);
  }

  // Crear o actualizar configuración
  Future<void> guardarConfiguracion(
      DesafioQrConfig config,
      ) async {
    await supabase
        .from('desafio_qr_config')
        .upsert({
      'id_desafio': config.idDesafio,
      'id_qr': config.idQr,
      'pista': config.pista,
    });
  }

  // Listar códigos QR de un museo
  Future<List<Map<String, dynamic>>> listarPorMuseo(
      String idMuseo,
      ) async {
    final data = await supabase
        .from('codigos_qr')
        .select()
        .eq('id_museo', idMuseo)
        .eq('estado', true);

    return (data as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // Crear código QR
  Future<void> crearCodigo({
    required String idMuseo,
    String? idObjeto,
    required String tokenHash,
    String? ubicacionReferencia,
  }) async {
    await supabase.from('codigos_qr').insert({
      'id_museo': idMuseo,
      'id_objeto': idObjeto,
      'token_hash': tokenHash,
      'ubicacion_referencia': ubicacionReferencia,
      'estado': true,
    });
  }

  // Desactivar código QR
  Future<void> cambiarEstadoCodigo(
      String idQr,
      bool estado,
      ) async {
    await supabase
        .from('codigos_qr')
        .update({'estado': estado})
        .eq('id_qr', idQr);
  }

  // Eliminar configuración de un desafío
  Future<void> eliminarConfiguracion(
      String idDesafio,
      ) async {
    await supabase
        .from('desafio_qr_config')
        .delete()
        .eq('id_desafio', idDesafio);
  }
}
