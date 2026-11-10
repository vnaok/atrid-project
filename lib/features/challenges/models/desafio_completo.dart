import "desafio_museo.dart";
import "desafio_busqueda_config.dart";
import 'desafio_identificacion_config.dart';
import 'desafio_opcion.dart';
import 'desafio_qr_config.dart';
class DesafioCompleto {
  final DesafioMuseo desafio;

  final List<DesafioOpcion> opciones;

  final DesafioBusquedaConfig? busquedaConfig;

  final DesafioQrConfig? qrConfig;

  final DesafioIdentificacionConfig? identificacionConfig;

  const DesafioCompleto({
    required this.desafio,
    this.opciones = const [],
    this.busquedaConfig,
    this.qrConfig,
    this.identificacionConfig,
  });
}
