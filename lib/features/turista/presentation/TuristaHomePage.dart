import 'package:flutter/material.dart';

import '../../../core/supabase/supabase_client.dart';

import '../model/Mision.dart';
import '../model/ObjetoMuseo.dart';
import '../model/VisitorState.dart';

import '../service/TuristaService.dart';

class TuristaHomePage extends StatefulWidget {
  final String museoId;

  const TuristaHomePage({
    super.key,
    required this.museoId,
  });

  @override
  State<TuristaHomePage> createState() => _TuristaHomePageState();
}

class _TuristaHomePageState extends State<TuristaHomePage> {
  late final TuristaService _turistaService;

  bool _loading = true;
  String? _error;

  List<Mision> _misiones = [];
  List<ObjetoMuseo> _objetos = [];

  VisitorState? _estadisticas;

  @override
  void initState() {
    super.initState();

    _turistaService = TuristaService(supabase);

    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final resultados = await Future.wait([
        _turistaService.obtenerMisiones(widget.museoId),
        _turistaService.obtenerObjetos(widget.museoId),
        _turistaService.obtenerEstadisticas(widget.museoId),
      ]);

      if (!mounted) return;

      final misiones = resultados[0] as List<Mision>;
      final objetos = resultados[1] as List<ObjetoMuseo>;
      final estadisticas = resultados[2] as VisitorState;

      debugPrint('Museo: ${widget.museoId}');
      debugPrint('Misiones cargadas: ${misiones.length}');
      debugPrint('Objetos cargados: ${objetos.length}');

      setState(() {
        _misiones = misiones;
        _objetos = objetos;
        _estadisticas = estadisticas;

        _loading = false;
        _error = null;
      });
    } catch (e, stackTrace) {
      debugPrint('ERROR AL CARGAR TURISTA HOMEPAGE: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      setState(() {
        _error = 'No se pudo cargar la información del museo.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5EFE6),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF8B6F47),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5EFE6),
        body: Center(
          child: Text(_error!),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,

        title: const Text(
          'Exploradores del Museo',
          style: TextStyle(
            color: Color(0xFF292621),
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Color(0xFF292621),
        ),
      ),

      body: RefreshIndicator(
        color: const Color(0xFF8B6F47),
        onRefresh: _cargarDatos,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildHeader(),

              const SizedBox(height: 24),

              _buildEstadisticas(),

              const SizedBox(height: 32),

              _buildSectionTitle(
                'Misiones',
                Icons.explore_rounded,
              ),

              const SizedBox(height: 12),

              _buildMisiones(),

              const SizedBox(height: 32),

              _buildSectionTitle(
                'Objetos del museo',
                Icons.museum_rounded,
              ),

              const SizedBox(height: 12),

              _buildObjetos(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8DFD0),
            Color(0xFFF4ECE0),
          ],
        ),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFD6CEC2),
        ),
      ),

      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(
            Icons.explore_rounded,
            color: Color(0xFF8B6F47),
            size: 32,
          ),

          SizedBox(height: 12),

          Text(
            'Tu exploración',
            style: TextStyle(
              color: Color(0xFF292621),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'Descubrí las historias y objetos '
                'que guarda el museo.',
            style: TextStyle(
              color: Color(0xFF756F68),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ESTADISTICAS
  // =========================================================

  Widget _buildEstadisticas() {
    final stats = _estadisticas!;

    return Row(
      children: [

        Expanded(
          child: _buildStatCard(
            icon: Icons.flag_rounded,
            value: '${stats.misionesCompletadas}',
            label: 'Misiones',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            icon: Icons.star_rounded,
            value: '${stats.puntos}',
            label: 'Puntos',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            icon: Icons.inventory_2_rounded,
            value: '${_objetos.length}',
            label: 'Objetos',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 10,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFD6CEC2),
        ),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color: const Color(0xFF8B6F47),
            size: 22,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF292621),
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF756F68),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TITULO SECCION
  // =========================================================

  Widget _buildSectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [

        Icon(
          icon,
          color: const Color(0xFF8B6F47),
          size: 22,
        ),

        const SizedBox(width: 8),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF292621),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // MISIONES
  // =========================================================

  Widget _buildMisiones() {
    if (_misiones.isEmpty) {
      return _buildEmptyMessage(
        'No hay misiones disponibles.',
      );
    }

    return Column(
      children: _misiones.map((mision) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),

          child: _buildMisionCard(mision),
        );
      }).toList(),
    );
  }

  Widget _buildMisionCard(Mision mision) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFD6CEC2),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color: const Color(0xFFF1EBE1),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.flag_rounded,
                  color: Color(0xFF8B6F47),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      mision.nombre,

                      style: const TextStyle(
                        color: Color(0xFF292621),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (mision.dificultad != null)
                      Text(
                        mision.dificultad!,

                        style: const TextStyle(
                          color: Color(0xFF8B6F47),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            mision.descripcion,

            style: const TextStyle(
              color: Color(0xFF756F68),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          if (mision.duracionEstimada != null) ...[
            const SizedBox(height: 12),

            Row(
              children: [

                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: Color(0xFF756F68),
                ),

                const SizedBox(width: 6),

                Text(
                  '${mision.duracionEstimada} min',

                  style: const TextStyle(
                    color: Color(0xFF756F68),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 44,

            child: OutlinedButton(
              onPressed: () {
                // Próximamente:
                // abrir detalle de misión
              },

              style: OutlinedButton.styleFrom(
                foregroundColor:
                const Color(0xFF8B6F47),

                side: const BorderSide(
                  color: Color(0xFF8B6F47),
                ),

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),

              child: const Text(
                'Ver misión',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // OBJETOS
  // =========================================================

  Widget _buildObjetos() {
    if (_objetos.isEmpty) {
      return _buildEmptyMessage(
        'No hay objetos disponibles.',
      );
    }

    return Column(
      children: _objetos.map((objeto) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),

          child: _buildObjetoCard(objeto),
        );
      }).toList(),
    );
  }

  Widget _buildObjetoCard(ObjetoMuseo objeto) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFD6CEC2),
        ),
      ),

      child: Row(
        children: [

          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(12),

            child: SizedBox(
              width: 78,
              height: 78,

              child: objeto.imagen != null &&
                  objeto.imagen!.isNotEmpty
                  ? Image.network(
                objeto.imagen!,
                fit: BoxFit.cover,

                errorBuilder:
                    (_, __, ___) {
                  return _buildImagePlaceholder();
                },
              )
                  : _buildImagePlaceholder(),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  objeto.nombre,

                  style: const TextStyle(
                    color: Color(0xFF292621),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  objeto.descripcion,

                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF756F68),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),

                if (objeto.ubicacion != null) ...[
                  const SizedBox(height: 7),

                  Row(
                    children: [

                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF8B6F47),
                        size: 15,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          objeto.ubicacion!,

                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Color(0xFF8B6F47),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFE8DFD0),

      child: const Icon(
        Icons.museum_rounded,
        color: Color(0xFF8B6F47),
        size: 32,
      ),
    );
  }

  // =========================================================
  // VACIO
  // =========================================================

  Widget _buildEmptyMessage(String message) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFD6CEC2),
        ),
      ),

      child: Text(
        message,
        textAlign: TextAlign.center,

        style: const TextStyle(
          color: Color(0xFF756F68),
          fontSize: 14,
        ),
      ),
    );
  }
}