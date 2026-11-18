import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import 'package:flutter/foundation.dart';

import '../../auth/services/AuthService.dart';
import '../../turista/service/visita_museo_service.dart';
import '../../turista/presentation/detalle_mision_page.dart';

import '../../turista/model/Mision.dart';

import '../../turista/model/ObjetoMuseo.dart';

import '../../turista/model/VisitorState.dart';

import '../../turista/service/TuristaService.dart';
import '../../turista/presentation/detalle_objeto_page.dart';

import '../../badges/models/badge.dart' as modelo;
import '../../badges/services/badgeService.dart';


class UserHomePage extends StatefulWidget {
  final String museoId;

  const UserHomePage({
    super.key,
    required this.museoId,
  });

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}




class _UserHomePageState extends State<UserHomePage> {


  late final TuristaService _turistaService;
  late final VisitaMuseoService _visitaMuseoService;


  bool _loading = true;
  String? _error;

  List<Mision> _misiones = [];
  List<ObjetoMuseo> _objetos = [];

  late final BadgeService _badgeService;

  List<modelo.Badge> _insignias = [];

  bool _cargandoInsignias = true;

  // Estadísticas temporales de la visita
  VisitorState _estadisticas = VisitorState(
    misionesCompletadas: 0,
    puntos: 0,
  );

// Registrar una misión finalizada
  void _registrarMisionFinalizada(int puntosGanados) {
    debugPrint('========== REGISTRAR MISIÓN ==========');
    debugPrint('Puntos recibidos: $puntosGanados');
    debugPrint('Puntos anteriores: ${_estadisticas.puntos}');

    if (!mounted) return;

    setState(() {
      _estadisticas = VisitorState(
        misionesCompletadas: _estadisticas.misionesCompletadas + 1,
        puntos: _estadisticas.puntos + puntosGanados,
      );
    });

    debugPrint('Puntos nuevos: ${_estadisticas.puntos}');
    debugPrint('======================================');
  }



  @override
  void initState() {
    super.initState();

    _turistaService = TuristaService(supabase);

    _badgeService = BadgeService(supabase);

    _cargarInsignias();
    _cargarDatos();

    _visitaMuseoService = VisitaMuseoService(
      Supabase.instance.client,
    );

    _registrarVisitaMuseo();
  }


  Future<void> _registrarVisitaMuseo() async {
    try {
      await _visitaMuseoService.registrarVisita(
        widget.museoId,
      );

      debugPrint('Visita al museo registrada');
    } catch (e) {
      debugPrint('Error al registrar visita: $e');
    }
  }


  Future<void> _cargarInsignias() async {
    try {
      final insignias = await _badgeService.listarPorMuseo(
        widget.museoId,
        soloActivas: true,
      );

      if (!mounted) return;

      setState(() {
        _insignias = insignias;
      });
    } catch (e) {
      debugPrint('Error al cargar insignias: $e');
    } finally {
      if (mounted) {
        setState(() {
          _cargandoInsignias = false;
        });
      }
    }
  }

  Future<void> _cargarDatos() async {
    try {
      final resultados = await Future.wait([
        _turistaService.obtenerMisiones(widget.museoId),
        _turistaService.obtenerObjetos(widget.museoId),
      ]);

      if (!mounted) return;

      final misiones = resultados[0] as List<Mision>;
      final objetos = resultados[1] as List<ObjetoMuseo>;

      debugPrint('Museo: ${widget.museoId}');
      debugPrint('Misiones cargadas: ${misiones.length}');
      debugPrint('Objetos cargados: ${objetos.length}');

      setState(() {
        _misiones = misiones;
        _objetos = objetos;

        // Estadísticas nuevas para esta visita
        _estadisticas = VisitorState(
          misionesCompletadas: 0,
          puntos: 0,
        );

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

              _buildZonaTrofeos(),

              const SizedBox(height: 24),
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
  // ESTADISTICAS CLAVEEEEEEEE
  // =========================================================

  Widget _buildEstadisticas() {
    final stats = _estadisticas!;

    return Row(
      children: [

        Expanded(
          child: _buildStatCard(
            icon: Icons.flag_rounded,
            value: '${_estadisticas.misionesCompletadas}',
            label: 'Misiones completadas',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            icon: Icons.star_rounded,
            value: '${_estadisticas.puntos}',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleMisionPage(
                      idMision: mision.id,
                      onMisionFinalizada: _registrarMisionFinalizada,
                      onVolverInicio: () {
                        Navigator.of(context).popUntil(
                              (route) => route.isFirst,
                        );
                      },
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B6F47),
                side: const BorderSide(
                  color: Color(0xFF8B6F47),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ver misión'),
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


  // =========================================================
  // TARJETA DE OBJETO
  // =========================================================

  Widget _buildObjetoCard(ObjetoMuseo objeto) {
    final String? rutaImagen = objeto.imagen?.trim();

    final String? imagenUrl =
    rutaImagen != null && rutaImagen.isNotEmpty
        ? supabase.storage
        .from('objetos-museo')
        .getPublicUrl(rutaImagen)
        : null;

    final bool tieneImagen =
        imagenUrl != null &&
            imagenUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleObjetoPage(
                objeto: objeto,
              ),
            ),
          );
        },

        child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ==========================================
              // MINIATURA DE LA IMAGEN
              // ==========================================

              ClipRRect(
                borderRadius: BorderRadius.circular(12),

                child: SizedBox(
                  width: 78,
                  height: 78,

                  child: tieneImagen
                      ? Image.network(
                    imagenUrl!,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,

                    // Mientras se descarga la imagen
                    loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                        ) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return _buildImagePlaceholder(
                        cargando: true,
                      );
                    },

                    // Si falla la descarga
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return _buildImagePlaceholder();
                    },
                  )
                      : _buildImagePlaceholder(),
                ),
              ),

              const SizedBox(width: 14),

              // ==========================================
              // INFORMACIÓN DEL OBJETO
              // ==========================================

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

                    if (objeto.ubicacion != null &&
                        objeto.ubicacion!.trim().isNotEmpty) ...[
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
                              overflow: TextOverflow.ellipsis,

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

              // Indicador visual de que se puede abrir
              const SizedBox(width: 8),

              const Padding(
                padding: EdgeInsets.only(top: 4),

                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFF8B6F47),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // PLACEHOLDER DE IMAGEN
  // =========================================================

  Widget _buildImagePlaceholder({
    bool cargando = false,
  }) {
    return Container(
      width: 78,
      height: 78,
      color: const Color(0xFFE8DFD0),

      child: Center(
        child: cargando
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF8B6F47),
          ),
        )
            : const Icon(
          Icons.museum_rounded,
          color: Color(0xFF8B6F47),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildZonaTrofeos() {
    if (_cargandoInsignias) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_insignias.isEmpty) {
      return const Text(
        'Todavía no hay insignias disponibles.',
      );
    }

    final desbloqueadas = _insignias.where((insignia) {
      return _estadisticas.puntos >= insignia.puntosRequeridos;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Zona de trofeos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF292621),
              ),
            ),
            Text(
              '$desbloqueadas/${_insignias.length}',
              style: const TextStyle(
                color: Color(0xFF8B6F47),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          'Conseguí puntos completando misiones para desbloquear insignias.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _insignias.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            return _buildTrofeoCard(_insignias[index]);
          },
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () async {
              try {
                final authService = AuthService(
                  Supabase.instance.client,
                );

                await authService.logout();

              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al cerrar sesión: $e'),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8B3A3A),
              side: const BorderSide(
                color: Color(0xFFD6CEC2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTrofeoCard(modelo.Badge insignia) {
    final desbloqueada =
        _estadisticas.puntos >= insignia.puntosRequeridos;

    final imagenUrl = _badgeService.obtenerImagenUrl(
      insignia.imagen,
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: desbloqueada
              ? const Color(0xFF8B6F47)
              : const Color(0xFFD6CEC2),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (imagenUrl != null)
                  Opacity(
                    opacity: desbloqueada ? 1 : 0.25,
                    child: Image.network(
                      imagenUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.workspace_premium_outlined,
                          size: 45,
                          color: Color(0xFF8B6F47),
                        );
                      },
                    ),
                  )
                else
                  Icon(
                    Icons.workspace_premium_outlined,
                    size: 45,
                    color: desbloqueada
                        ? const Color(0xFF8B6F47)
                        : Colors.grey,
                  ),

                if (!desbloqueada)
                  const Icon(
                    Icons.lock_rounded,
                    size: 30,
                    color: Color(0xFF292621),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            insignia.nombre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF292621),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            desbloqueada
                ? 'Desbloqueada'
                : '${insignia.puntosRequeridos} puntos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: desbloqueada
                  ? const Color(0xFF66834D)
                  : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),


        ],

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