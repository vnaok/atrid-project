
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:prueba_flutter/features/challenges/models/desafio_museo.dart';
import 'package:prueba_flutter/features/challenges/models/desafio_opcion_publica.dart';
import 'package:prueba_flutter/features/challenges/services/desafio_service.dart';
import 'package:prueba_flutter/features/challenges/services/desafio_opcionpublicaservice.dart';
import 'package:prueba_flutter/features/challenges/services/intento_desafio_service.dart';
import 'package:prueba_flutter/features/challenges/models/desafio_identificacion_config.dart';
import 'package:prueba_flutter/features/challenges/services/desafio_identificacionservice.dart';
import 'package:prueba_flutter/features/turista/presentation/MisionFinalizadaPage.dart';

class MisionEnCursoPage extends StatefulWidget {
  final String idMision;
  final ValueChanged<int> onMisionFinalizada;
  final VoidCallback onVolverInicio;


  const MisionEnCursoPage({
    super.key,
    required this.idMision,
    required this.onVolverInicio,
    required this.onMisionFinalizada,
  });

  @override
  State<MisionEnCursoPage> createState() => _MisionEnCursoPageState();
}



class _MisionEnCursoPageState extends State<MisionEnCursoPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  late final DesafioService _desafioService;
  late final DesafioOpcionService _opcionService;
  late final IntentoDesafioService _intentoService;

  late final DesafioIdentificacionService _identificacionService;

  DesafioIdentificacionConfig? _configIdentificacion;

  Map<String, dynamic>? _objetoIdentificacion;

  List<DesafioMuseo> _preguntas = [];
  List<DesafioOpcionPublica> _opciones = [];

  int _indiceActual = 0;
  int _puntajeTotal = 0;
  int _desafiosCompletados = 0;
  int _respuestasCorrectas = 0;

  String? _opcionSeleccionada;

  bool _cargando = true;
  bool _enviandoRespuesta = false;
  bool _respuestaEnviada = false;
  bool _respuestaCorrecta = false;

  String? _error;

  static const Color fondo = Color(0xFFF5EFE6);
  static const Color texto = Color(0xFF292621);
  static const Color borde = Color(0xFFD6CEC2);
  static const Color acento = Color(0xFF8B6F47);

  @override
  void initState() {

    super.initState();

    _identificacionService =
        DesafioIdentificacionService(_supabase);

    debugPrint(
      'CURSO: ${widget.onMisionFinalizada != null}',
    );
    debugPrint(
      'MisionEnCursoPage callback: ${widget.onMisionFinalizada != null}',
    );
    print('========== INIT STATE EJECUTADO ==========');
    print('ID RECIBIDO: ${widget.idMision}');

    _desafioService = DesafioService(_supabase);
    _opcionService = DesafioOpcionService(_supabase);
    _intentoService = IntentoDesafioService(_supabase);

    print('========== SERVICIOS INICIALIZADOS ==========');

    _cargarPreguntas();
  }


  Future<void> _cargarDatosDesafio(
      DesafioMuseo desafio,
      ) async {
    String etapa = 'Inicio';

    debugPrint('');
    debugPrint('========================================');
    debugPrint('INICIO DE CARGA DE DESAFÍO');
    debugPrint('========================================');

    debugPrint('ID DESAFÍO: ${desafio.idDesafio}');
    debugPrint('TIPO DESAFÍO: ${desafio.tipo}');
    debugPrint('TIPO BD: ${desafio.tipo.toString().split('.').last}');

    try {
      // ETAPA 1: Cargar alternativas.
      etapa = 'Cargar alternativas';

      debugPrint('ETAPA 1: $etapa');

      final opciones = await _opcionService.listarPorDesafio(
        desafio.idDesafio,
      );

      debugPrint('ALTERNATIVAS ENCONTRADAS: ${opciones.length}');

      for (final opcion in opciones) {
        debugPrint(
          'OPCIÓN: ${opcion.idOpcion} | ${opcion.texto}',
        );
      }

      DesafioIdentificacionConfig? configuracion;
      Map<String, dynamic>? objeto;

      // ETAPA 2: Recuperar configuración de identificación.
      if (desafio.tipo == TipoDesafio.identificacion) {
        etapa = 'Recuperar configuración de identificación';

        debugPrint('ETAPA 2: $etapa');
        debugPrint(
          'ID UTILIZADO PARA BUSCAR CONFIGURACIÓN: ${desafio.idDesafio}',
        );

        configuracion = await _identificacionService.obtener(
          desafio.idDesafio,
        );

        debugPrint('RESULTADO DE OBTENER(): $configuracion');

        if (configuracion == null) {
          debugPrint('ERROR: OBTENER() DEVOLVIÓ NULL');

          throw Exception(
            'El desafío no tiene una configuración de identificación.',
          );
        }

        debugPrint(
          'ID DESAFÍO CONFIGURACIÓN: ${configuracion.idDesafio}',
        );

        debugPrint(
          'ID OBJETO CORRECTO: ${configuracion.idObjetoCorrecto}',
        );

        debugPrint(
          'TIPO IDENTIFICACIÓN: ${configuracion.tipoIdentificacion}',
        );

        // ETAPA 3: Validar objeto asociado.
        etapa = 'Validar objeto asociado';

        debugPrint('ETAPA 3: $etapa');

        final idObjeto = configuracion.idObjetoCorrecto;

        if (idObjeto == null || idObjeto.isEmpty) {
          throw Exception(
            'La configuración no tiene un objeto correcto asignado.',
          );
        }

        // ETAPA 4: Consultar objeto.
        etapa = 'Consultar objeto en Supabase';

        debugPrint('ETAPA 4: $etapa');
        debugPrint('ID OBJETO BUSCADO: $idObjeto');

        objeto = await _supabase
            .from('objetos')
            .select('id_objeto, nombre, imagen')
            .eq('id_objeto', idObjeto)
            .single();

        debugPrint('OBJETO RECUPERADO: $objeto');
      } else {
        debugPrint(
          'EL DESAFÍO NO ES DE IDENTIFICACIÓN. '
              'Se omite la configuración especial.',
        );
      }

      // ETAPA 5: Actualizar interfaz.
      etapa = 'Actualizar estado de pantalla';

      debugPrint('ETAPA 5: $etapa');

      if (!mounted) {
        debugPrint('WIDGET DESMONTADO. SE CANCELA LA ACTUALIZACIÓN.');
        return;
      }

      setState(() {
        _opciones = opciones;
        _configIdentificacion = configuracion;
        _objetoIdentificacion = objeto;

        _opcionSeleccionada = null;
        _respuestaEnviada = false;
        _respuestaCorrecta = false;

        _cargando = false;
        _error = null;
      });

      debugPrint('DESAFÍO CARGADO CORRECTAMENTE.');
      debugPrint('========================================');
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('========================================');
      debugPrint('ERROR AL CARGAR DESAFÍO');
      debugPrint('ETAPA DEL ERROR: $etapa');
      debugPrint('ID DESAFÍO: ${desafio.idDesafio}');
      debugPrint('TIPO DESAFÍO: ${desafio.tipo}');
      debugPrint('ERROR COMPLETO: $e');
      debugPrint('STACKTRACE: $stackTrace');
      debugPrint('========================================');

      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = 'No fue posible cargar el desafío: $e';
      });
    }
  }

  String? _obtenerUrlImagen(String? imagen) {
    if (imagen == null || imagen.trim().isEmpty) {
      return null;
    }

    final ruta = imagen.trim();

    if (ruta.startsWith('https://') ||
        ruta.startsWith('http://')) {
      return ruta;
    }

    return _supabase.storage
        .from('objetos-museo')
        .getPublicUrl(ruta);
  }

  Future<void> _cargarPreguntas() async {
    try {
      setState(() {
        _cargando = true;
        _error = null;
      });

      // MODIFICACIÓN 1:
      // Ahora recuperamos TODOS los tipos de desafíos activos.
      final preguntas = await _desafioService.listarPorMision(
        widget.idMision,
        soloActivos: true,
      );

      if (preguntas.isEmpty) {
        if (!mounted) return;

        setState(() {
          _preguntas = [];
          _cargando = false;
          _error = 'Esta misión todavía no tiene desafíos disponibles.';
        });

        return;
      }

      if (!mounted) return;

      // MODIFICACIÓN 2:
      // Guardamos los desafíos y establecemos el primero.
      setState(() {
        _preguntas = preguntas;
        _indiceActual = 0;
      });

      // MODIFICACIÓN 3:
      // Cargamos los datos según el tipo del primer desafío.
      await _cargarDatosDesafio(preguntas.first);

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = 'No fue posible cargar los desafíos: $e';
      });
    }
  }

  DesafioMuseo get _preguntaActual => _preguntas[_indiceActual];

  bool get _esUltimaPregunta =>
      _indiceActual == _preguntas.length - 1;

  Future<void> _seleccionarSiguiente() async {
    if (_indiceActual >= _preguntas.length - 1) {
      _finalizarMision();
      return;
    }

    final siguiente = _indiceActual + 1;

    try {
      setState(() {
        _cargando = true;
        _error = null;
      });

      final opciones = await _opcionService.listarPorDesafio(
        _preguntas[siguiente].idDesafio,
      );

      if (!mounted) return;

      setState(() {
        _indiceActual = siguiente;
        _opciones = opciones;
        _opcionSeleccionada = null;
        _respuestaEnviada = false;
        _respuestaCorrecta = false;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = 'No fue posible cargar la siguiente pregunta: $e';
      });
    }
  }



  Future<void> probarCargaTrivia() async {
    final supabase = Supabase.instance.client;

    try {
      final data = await supabase
          .from('desafios')
          .select()
          .eq('id_mision', widget.idMision)
          .eq('estado', true)
          .order('orden');

      debugPrint('TOTAL DESAFÍOS: ${data.length}');

      final preguntas = data
          .map((item) => DesafioMuseo.fromMap(
        Map<String, dynamic>.from(item),
      ))
          .toList();

      debugPrint('TOTAL MODELOS: ${preguntas.length}');

      for (final pregunta in preguntas) {
        debugPrint(
          'TÍTULO: ${pregunta.titulo} | '
              'TIPO: ${pregunta.tipo} | '
              'ES PREGUNTA: ${pregunta.tipo == TipoDesafio.pregunta}',
        );
      }

      if (preguntas.isNotEmpty) {
        final opciones = await supabase
            .from('desafio_opciones')
            .select('id_opcion, id_desafio, texto, imagen, orden')
            .eq('id_desafio', preguntas.first.idDesafio)
            .order('orden');

        debugPrint('TOTAL OPCIONES: ${opciones.length}');
        debugPrint('OPCIONES: $opciones');
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR EN PRUEBA: $e');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _validarRespuesta() async {
    if (_opcionSeleccionada == null ||
        _respuestaEnviada ||
        _enviandoRespuesta) {
      return;
    }

    try {
      setState(() {
        _enviandoRespuesta = true;
        _error = null;
      });

      final resultado = await _intentoService.responderPregunta(
        idDesafio: _preguntaActual.idDesafio,
        idOpcion: _opcionSeleccionada!,
      );

      final correcta = resultado['correcta'] == true;

      final puntos = (resultado['puntos_obtenidos'] as num?)
          ?.toInt() ??
          0;

      if (!mounted) return;

      setState(() {
        _respuestaEnviada = true;
        _respuestaCorrecta = correcta;
        _desafiosCompletados++;

        if (correcta) {
          _respuestasCorrectas++;
        }

        _puntajeTotal += puntos;
        _enviandoRespuesta = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _enviandoRespuesta = false;
        _error = 'No se pudo validar la respuesta: $e';
      });
    }
  }

  void _finalizarMision() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MisionFinalizadaPage(
          puntajeObtenido: _puntajeTotal,
          desafiosCompletados: _desafiosCompletados,
          totalDesafios: _preguntas.length,
          respuestasCorrectas: _respuestasCorrectas,
          onMisionFinalizada: widget.onMisionFinalizada,
          onVolverInicio: widget.onVolverInicio,
        ),
      ),
    );
  }



  Widget _construirOpcion(DesafioOpcionPublica opcion) {
    final seleccionada = _opcionSeleccionada == opcion.idOpcion;

    return GestureDetector(
      onTap: _respuestaEnviada || _enviandoRespuesta
          ? null
          : () {
        setState(() {
          _opcionSeleccionada = opcion.idOpcion;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: seleccionada
              ? acento.withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionada ? acento : borde,
            width: seleccionada ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              seleccionada
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: seleccionada ? acento : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                opcion.texto,
                style: const TextStyle(
                  fontSize: 15,
                  color: texto,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirResultadoRespuesta() {
    final color = _respuestaCorrecta
        ? Colors.green.shade700
        : Colors.red.shade700;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(
            _respuestaCorrecta
                ? Icons.check_circle
                : Icons.cancel,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _respuestaCorrecta
                  ? '¡Respuesta correcta! Has obtenido puntos.'
                  : 'Respuesta incorrecta. ¡Continuá explorando!',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('========== BUILD MISION EN CURSO ==========');
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: fondo,
        foregroundColor: texto,
        elevation: 0,
        title: const Text(
          'Misión en curso',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _construirContenido(),
      ),
    );
  }

  Widget _construirReferenciaIdentificacion() {
    if (_configIdentificacion == null ||
        _objetoIdentificacion == null) {
      return const SizedBox.shrink();
    }

    final objeto = _objetoIdentificacion!;
    final nombre = objeto['nombre']?.toString() ?? 'Objeto';
    final imagen = objeto['imagen']?.toString();
    final urlImagen = _obtenerUrlImagen(imagen);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Objeto de referencia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: texto,
            ),
          ),

          const SizedBox(height: 12),

          if (urlImagen != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                urlImagen,
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error imagen identificación: $error');

                  return const SizedBox(
                    height: 150,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 45,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const SizedBox(
              height: 120,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 45,
                ),
              ),
            ),

          const SizedBox(height: 12),

          Text(
            nombre,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: texto,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Característica a identificar: '
                '${_configIdentificacion!.tipoIdentificacion}',
            style: const TextStyle(
              fontSize: 14,
              color: texto,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: acento),
      );
    }

    if (_error != null && _preguntas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: acento,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: texto),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _cargarPreguntas,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_preguntas.isEmpty) {
      return const Center(
        child: Text('No hay preguntas disponibles.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progreso de la misión
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Desafío ${_indiceActual + 1} de ${_preguntas.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: texto,
                ),
              ),
              Text(
                '$_puntajeTotal puntos',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: acento,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_indiceActual + 1) / _preguntas.length,
              minHeight: 9,
              backgroundColor: borde,
              valueColor: const AlwaysStoppedAnimation(acento),
            ),
          ),

          const SizedBox(height: 30),

          // Tipo de desafío
          Text(
            _preguntaActual.tipo.toString().split('.').last.toUpperCase(),
            style: const TextStyle(
              color: acento,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          if (_preguntaActual.tipo == TipoDesafio.identificacion)
            _construirReferenciaIdentificacion(),

          // Enunciado
          Text(
            _preguntaActual.titulo,
            style: const TextStyle(
              color: texto,
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            _preguntaActual.descripcion,
            style: TextStyle(
              color: texto.withOpacity(0.75),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Seleccioná una respuesta:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: texto,
            ),
          ),

          const SizedBox(height: 16),

          if (_opciones.isEmpty)
            const Text(
              'Esta pregunta no tiene opciones disponibles.',
              style: TextStyle(color: texto),
            )
          else
            ..._opciones.map(_construirOpcion),

          if (_respuestaEnviada)
            _construirResultadoRespuesta(),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _enviandoRespuesta
                  ? null
                  : _respuestaEnviada
                  ? _seleccionarSiguiente
                  : _opcionSeleccionada == null ||
                  _opciones.isEmpty
                  ? null
                  : _validarRespuesta,
              style: ElevatedButton.styleFrom(
                backgroundColor: texto,
                foregroundColor: fondo,
                disabledBackgroundColor: borde,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _enviandoRespuesta
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fondo,
                ),
              )
                  : Text(
                _respuestaEnviada
                    ? _esUltimaPregunta
                    ? 'Finalizar misión'
                    : 'Siguiente desafío'
                    : 'Confirmar respuesta',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



