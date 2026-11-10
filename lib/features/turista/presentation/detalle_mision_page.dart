import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:prueba_flutter/features/turista/presentation/widgets/desafio_preview_card.dart';
import 'package:prueba_flutter/features/challenges/services/desafio_service.dart';
import 'package:prueba_flutter/features/challenges/models/desafio_museo.dart';
//import 'package:prueba_flutter/features/turista/presentation/MisionFinalizadaPage.dart';
import 'package:prueba_flutter/features/turista/presentation/MisionEnCursoPage.dart';



class DetalleMisionPage extends StatefulWidget {
  final String idMision;


  final ValueChanged<int> onMisionFinalizada;

  const DetalleMisionPage({
    super.key,
    required this.idMision,
    required this.onMisionFinalizada,
  });

  @override
  State<DetalleMisionPage> createState() =>
      _DetalleMisionPageState();
}



class _DetalleMisionPageState extends State<DetalleMisionPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  late final DesafioService _desafioService =
  DesafioService(_supabase);

  static const Color fondo = Color(0xFFF5EFE6);
  static const Color texto = Color(0xFF292621);
  static const Color borde = Color(0xFFD6CEC2);
  static const Color acento = Color(0xFF8B6F47);

  bool _cargando = true;
  String? _error;

  Map<String, dynamic>? _mision;

  List<DesafioMuseo> _desafios = [];

  @override
  void initState() {
    super.initState();
    _cargarMision();
  }



  void _realizarMision() {

    debugPrint(
      'DETALLE INIT: ${widget.onMisionFinalizada != null}',
    );
    debugPrint(
      'DETALLE: ${widget.onMisionFinalizada != null}',
    );
    debugPrint(
      'DetalleMisionPage callback: ${widget.onMisionFinalizada != null}',
    );
    final tienePreguntas = _desafios.any(
          (desafio) => desafio.tipo == TipoDesafio.pregunta,
    );

    if (!tienePreguntas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta misión todavía no tiene preguntas disponibles.',
          ),
        ),
      );
      return;
    }
    debugPrint(
      'DetalleMisionPage callback: ${widget.onMisionFinalizada != null}',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MisionEnCursoPage(
          idMision: widget.idMision,
          onMisionFinalizada: widget.onMisionFinalizada,
        ),
      ),
    );
  }

  // =========================================================
  // CARGAR INFORMACIÓN DE LA MISIÓN Y SUS DESAFÍOS
  // =========================================================

  Future<void> _cargarMision() async {
    try {
      setState(() {
        _cargando = true;
        _error = null;
      });

      // Obtener información de la misión.
      final mision = await _supabase
          .from('misiones')
          .select(
        'id_mision, nombre, descripcion, imagen, '
            'duracion_estimada, dificultad, estado',
      )
          .eq('id_mision', widget.idMision)
          .eq('estado', 'publicada')
          .maybeSingle();

      if (mision == null) {
        throw Exception('La misión no está disponible.');
      }

      // Obtener desafíos mediante DesafioService.
      final desafios = await _desafioService.listarPorMision(
        widget.idMision,
        soloActivos: true,
      );

      if (!mounted) return;

      setState(() {
        _mision = mision;
        _desafios = desafios;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  // =========================================================
  // CONSTRUIR IMAGEN
  // =========================================================

  Widget _construirImagen(String? imagen) {
    if (imagen == null ||
        imagen.isEmpty ||
        !imagen.startsWith('http')) {
      return Container(
        height: 220,
        width: double.infinity,
        color: const Color(0xFFE9E0D4),
        child: const Icon(
          Icons.museum_outlined,
          size: 65,
          color: acento,
        ),
      );
    }

    return Image.network(
      imagen,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          height: 220,
          color: const Color(0xFFE9E0D4),
          child: const Icon(
            Icons.image_not_supported_outlined,
            size: 55,
            color: acento,
          ),
        );
      },
    );
  }

  // =========================================================
  // CONSTRUIR DATOS GENERALES
  // =========================================================

  Widget _construirDato({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE5DA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icono, color: acento, size: 22),
            const SizedBox(height: 7),
            Text(
              valor,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: texto,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: texto.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CONSTRUIR LISTADO DE DESAFÍOS
  // =========================================================

  Widget _construirDesafios() {
    if (_desafios.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: Border.all(color: borde),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Esta misión todavía no tiene desafíos disponibles.',
          textAlign: TextAlign.center,
          style: TextStyle(color: texto),
        ),
      );
    }

    return Column(
      children: _desafios.map((desafio) {
        return DesafioPreviewCard(
          orden: desafio.orden,
          titulo: desafio.titulo,
          descripcion: desafio.descripcion ?? 'Sin descripción.',
          tipo: desafio.tipo.name,
          puntos: desafio.puntos,
        );
      }).toList(),
    );
  }

  // =========================================================
  // CONSTRUIR CONTENIDO PRINCIPAL
  // =========================================================

  Widget _construirContenido() {
    final mision = _mision!;

    final nombre = mision['nombre']?.toString() ?? 'Misión';

    final descripcion =
        mision['descripcion']?.toString() ??
            'No hay una descripción disponible.';

    final imagen = mision['imagen']?.toString();

    final dificultad =
        mision['dificultad']?.toString() ?? 'Sin especificar';

    final duracion = mision['duracion_estimada'] as int?;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen principal.
          _construirImagen(imagen),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre.
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: texto,
                  ),
                ),

                const SizedBox(height: 16),

                // Información general.
                Row(
                  children: [
                    _construirDato(
                      icono: Icons.signal_cellular_alt,
                      titulo: 'Dificultad',
                      valor: dificultad,
                    ),
                    const SizedBox(width: 10),
                    _construirDato(
                      icono: Icons.schedule_outlined,
                      titulo: 'Duración',
                      valor: duracion != null
                          ? '$duracion min'
                          : 'Sin definir',
                    ),
                    const SizedBox(width: 10),
                    _construirDato(
                      icono: Icons.extension_outlined,
                      titulo: 'Desafíos',
                      valor: '${_desafios.length}',
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // Descripción.
                const Text(
                  'Acerca de esta misión',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: texto,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: texto.withOpacity(0.85),
                  ),
                ),

                const SizedBox(height: 28),

                // Desafíos.
                const Text(
                  'Desafíos de la misión',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: texto,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Estos son los desafíos que tendrás que completar.',
                  style: TextStyle(
                    fontSize: 13,
                    color: texto.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 12),

                _construirDesafios(),

                const SizedBox(height: 28),

                // Botón para realizar misión.-------------------------------------------------------------------------------------------------------------------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print('========== BOTON PRESIONADO ==========');
                      print('ID MISION: ${widget.idMision}');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MisionEnCursoPage(
                            idMision: widget.idMision,
                            onMisionFinalizada: widget.onMisionFinalizada,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'Realizar misión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF292621),
                      foregroundColor: const Color(0xFFF5EFE6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: fondo,
        foregroundColor: texto,
        elevation: 0,
        title: const Text(
          'Detalle de misión',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _cargando
          ? const Center(
        child: CircularProgressIndicator(color: acento),
      )
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: acento,
                size: 45,
              ),
              const SizedBox(height: 12),
              Text(
                'No se pudo cargar la misión.\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: texto),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarMision,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      )
          : _construirContenido(),
    );
  }
}