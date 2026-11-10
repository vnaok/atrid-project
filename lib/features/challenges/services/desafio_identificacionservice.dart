
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/desafio_identificacion_config.dart';

class DesafioIdentificacionService {
  final SupabaseClient supabase;

  DesafioIdentificacionService(this.supabase);

  // Obtener configuración
  Future<DesafioIdentificacionConfig?> obtener(
      String idDesafio,
      ) async {
    final data = await supabase
        .from('desafio_identificacion_config')
        .select()
        .eq('id_desafio', idDesafio)
        .maybeSingle();

    if (data == null) return null;

    return DesafioIdentificacionConfig.fromMap(data);
  }

  // Crear configuración
  Future<void> crear(
      DesafioIdentificacionConfig config,
      ) async {
    await supabase
        .from('desafio_identificacion_config')
        .insert({
      'id_desafio': config.idDesafio,
      'id_objeto_correcto': config.idObjetoCorrecto,
      'imagen_referencia': config.imagenReferencia,
      'tipo_identificacion': config.tipoIdentificacion,
    });
  }

  // Actualizar configuración
  Future<void> actualizar(
      DesafioIdentificacionConfig config,
      ) async {
    await supabase
        .from('desafio_identificacion_config')
        .update({
      'id_objeto_correcto': config.idObjetoCorrecto,
      'imagen_referencia': config.imagenReferencia,
      'tipo_identificacion': config.tipoIdentificacion,
    })
        .eq('id_desafio', config.idDesafio);
  }

  // Crear o actualizar
  Future<void> guardar(
      DesafioIdentificacionConfig config,
      ) async {
    await supabase
        .from('desafio_identificacion_config')
        .upsert({
      'id_desafio': config.idDesafio,
      'id_objeto_correcto': config.idObjetoCorrecto,
      'imagen_referencia': config.imagenReferencia,
      'tipo_identificacion': config.tipoIdentificacion,
    });
  }

  // Eliminar configuración
  Future<void> eliminar(String idDesafio) async {
    await supabase
        .from('desafio_identificacion_config')
        .delete()
        .eq('id_desafio', idDesafio);
  }
}
