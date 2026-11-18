import 'package:supabase_flutter/supabase_flutter.dart';

class VisitaMuseoService {
  final SupabaseClient supabase;

  VisitaMuseoService(this.supabase);

  Future<void> registrarVisita(String idMuseo) async {
    final usuario = supabase.auth.currentUser;

    await supabase.from('visitas_museo').insert({
      'id_museo': idMuseo,
      'id_usuario': usuario?.id,
    });
  }
}