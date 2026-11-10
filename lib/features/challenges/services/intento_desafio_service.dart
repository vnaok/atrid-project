import 'package:supabase_flutter/supabase_flutter.dart';

class IntentoDesafioService {
  final SupabaseClient supabase;

  IntentoDesafioService(this.supabase);

  Future<Map<String, dynamic>> responderPregunta({
    required String idDesafio,
    required String idOpcion,
  }) async {
    final resultado = await supabase.rpc(
      'validar_respuesta_trivia',
      params: {
        'p_id_desafio': idDesafio,
        'p_id_opcion': idOpcion,
      },
    );

    if (resultado is! Map) {
      throw Exception('La respuesta del servidor no es válida.');
    }

    return Map<String, dynamic>.from(resultado);
  }
}