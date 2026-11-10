
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/desafio_busqueda_config.dart';

class DesafioBusquedaService {
  final SupabaseClient supabase;

  DesafioBusquedaService(this.supabase);

  // Obtener configuración
  Future<DesafioBusquedaConfig?> obtener(
      String idDesafio,
      ) async {
    final data = await supabase
        .from('desafio_busqueda_config')
        .select()
        .eq('id_desafio', idDesafio)
        .maybeSingle();

    if (data == null) return null;

    return DesafioBusquedaConfig.fromMap(data);
  }

  // Crear configuración
  Future<void> crear(
      DesafioBusquedaConfig config,
      ) async {
    await supabase
        .from('desafio_busqueda_config')
        .insert({
      'id_desafio': config.idDesafio,
      'descripcion_referencia': config.descripcionReferencia,
      'etiquetas_esperadas': config.etiquetasEsperadas,
      'umbral_confianza': config.umbralConfianza,
    });
  }

  // Actualizar configuración
  Future<void> actualizar(
      DesafioBusquedaConfig config,
      ) async {
    await supabase
        .from('desafio_busqueda_config')
        .update({
      'descripcion_referencia': config.descripcionReferencia,
      'etiquetas_esperadas': config.etiquetasEsperadas,
      'umbral_confianza': config.umbralConfianza,
    })
        .eq('id_desafio', config.idDesafio);
  }

  // Eliminar configuración
  Future<void> eliminar(String idDesafio) async {
    await supabase
        .from('desafio_busqueda_config')
        .delete()
        .eq('id_desafio', idDesafio);
  }

  // Crear o actualizar
  Future<void> guardar(
      DesafioBusquedaConfig config,
      ) async {
    await supabase
        .from('desafio_busqueda_config')
        .upsert({
      'id_desafio': config.idDesafio,
      'descripcion_referencia': config.descripcionReferencia,
      'etiquetas_esperadas': config.etiquetasEsperadas,
      'umbral_confianza': config.umbralConfianza,
    });
  }
}
