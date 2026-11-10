
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/desafio_museo.dart';
import '../models/desafio_opcion.dart';
import '../models/desafio_completo.dart';
import '../models/desafio_busqueda_config.dart';
import '../models/desafio_qr_config.dart';
import '../models/desafio_identificacion_config.dart';

class DesafioCompletoService {
  final SupabaseClient supabase;

  DesafioCompletoService(this.supabase);

  // Obtener un desafío completo
  Future<DesafioCompleto?> obtener(String idDesafio) async {
    final desafioData = await supabase
        .from('desafios')
        .select()
        .eq('id_desafio', idDesafio)
        .maybeSingle();

    if (desafioData == null) return null;

    final desafio = DesafioMuseo.fromMap(desafioData);

    List<DesafioOpcion> opciones = [];
    DesafioBusquedaConfig? busquedaConfig;
    DesafioQrConfig? qrConfig;
    DesafioIdentificacionConfig? identificacionConfig;

    switch (desafio.tipo) {
      case TipoDesafio.pregunta:
        opciones = await _listarOpciones(idDesafio);
        break;

      case TipoDesafio.busquedaObjeto:
        busquedaConfig = await _obtenerBusqueda(idDesafio);
        break;

      case TipoDesafio.escaneoQr:
        qrConfig = await _obtenerQr(idDesafio);
        break;

      case TipoDesafio.identificacion:
        opciones = await _listarOpciones(idDesafio);
        identificacionConfig =
        await _obtenerIdentificacion(idDesafio);
        break;
    }

    return DesafioCompleto(
      desafio: desafio,
      opciones: opciones,
      busquedaConfig: busquedaConfig,
      qrConfig: qrConfig,
      identificacionConfig: identificacionConfig,
    );
  }

  Future<List<DesafioOpcion>> _listarOpciones(
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

  Future<DesafioBusquedaConfig?> _obtenerBusqueda(
      String idDesafio,
      ) async {
    final data = await supabase
        .from('desafio_busqueda_config')
        .select()
        .eq('id_desafio', idDesafio)
        .maybeSingle();

    return data == null
        ? null
        : DesafioBusquedaConfig.fromMap(data);
  }

  Future<DesafioQrConfig?> _obtenerQr(
      String idDesafio,
      ) async {
    final data = await supabase
        .from('desafio_qr_config')
        .select()
        .eq('id_desafio', idDesafio)
        .maybeSingle();

    return data == null
        ? null
        : DesafioQrConfig.fromMap(data);
  }

  Future<DesafioIdentificacionConfig?> _obtenerIdentificacion(
      String idDesafio,
      ) async {
    final data = await supabase
        .from('desafio_identificacion_config')
        .select()
        .eq('id_desafio', idDesafio)
        .maybeSingle();

    return data == null
        ? null
        : DesafioIdentificacionConfig.fromMap(data);
  }
}
