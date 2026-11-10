import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/desafio_opcion_publica.dart';

class DesafioOpcionService {
  final SupabaseClient supabase;

  DesafioOpcionService(this.supabase);

  Future<List<DesafioOpcionPublica>> listarPorDesafio(
      String idDesafio,
      ) async {
    final data = await supabase
        .from('desafio_opciones')
        .select('id_opcion, id_desafio, texto, imagen, orden')
        .eq('id_desafio', idDesafio)
        .order('orden');

    return (data as List)
        .map(
          (item) => DesafioOpcionPublica.fromMap(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }
}