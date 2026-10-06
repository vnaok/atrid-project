import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Mission.dart';
import '../services/MissionService.dart';
import 'FormMisionPage.dart';

class GestionarMisionesPage extends StatefulWidget {
  final String museoId;

  const GestionarMisionesPage({
    super.key,
    required this.museoId,
  });

  @override
  State<GestionarMisionesPage> createState() =>
      _GestionarMisionesPageState();
}

class _GestionarMisionesPageState
    extends State<GestionarMisionesPage> {

  late final MissionService _misionService;

  List<Mission> _misiones = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _misionService = MissionService(
      Supabase.instance.client,
    );

    _cargarMisiones();
  }

  Future<void> _cargarMisiones() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final misiones = await _misionService
          .obtenerMisiones(widget.museoId);

      if (!mounted) return;

      setState(() {
        _misiones = misiones;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'No se pudieron cargar las misiones.';
      });

      debugPrint('ERROR MISIONS: $e');
    }
  }

  Future<void> _crearMision() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormMisionPage(
          museoId: widget.museoId,
        ),
      ),
    );

    if (resultado == true) {
      _cargarMisiones();
    }
  }

  Future<void> _editarMision(Mission mision) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormMisionPage(
          museoId: widget.museoId,
          mision: mision,
        ),
      ),
    );

    if (resultado == true) {
      _cargarMisiones();
    }
  }

  Future<void> _eliminarMision(Mission mision) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar misión'),
          content: Text(
            '¿Está seguro de eliminar "${mision.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await _misionService.eliminarMision(
        mision.idMision,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Misión eliminada correctamente.'),
        ),
      );

      _cargarMisiones();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar la misión.'),
        ),
      );

      debugPrint('ERROR ELIMINANDO MISION: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        foregroundColor: const Color(0xFF292621),
        elevation: 0,
        title: const Text('Gestionar misiones'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _crearMision,
        backgroundColor: const Color(0xFF8B6F47),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _cargarMisiones,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_misiones.isEmpty) {
      return const Center(
        child: Text(
          'No hay misiones creadas.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF756F68),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarMisiones,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _misiones.length,
        itemBuilder: (context, index) {
          final mision = _misiones[index];

          return _MisionCard(
            mision: mision,
            onEditar: () => _editarMision(mision),
            onEliminar: () => _eliminarMision(mision),
          );
        },
      ),
    );
  }
}

class _MisionCard extends StatelessWidget {
  final Mission mision;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _MisionCard({
    required this.mision,
    required this.onEditar,
    required this.onEliminar,
  });

  Color _colorEstado() {
    switch (mision.estado) {
      case 'publicada':
        return Colors.green;
      case 'archivada':
        return Colors.grey;
      case 'borrador':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFD6CEC2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Expanded(
                  child: Text(
                    mision.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF292621),
                    ),
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      onEditar();
                    }

                    if (value == 'eliminar') {
                      onEliminar();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'editar',
                      child: Text('Editar'),
                    ),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),

            if (mision.descripcion != null &&
                mision.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 8),

              Text(
                mision.descripcion!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF756F68),
                ),
              ),
            ],

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(
                  icon: Icons.signal_cellular_alt,
                  text: mision.dificultad,
                ),

                if (mision.duracionEstimada != null)
                  _Tag(
                    icon: Icons.timer_outlined,
                    text: '${mision.duracionEstimada} min',
                  ),

                _Tag(
                  icon: Icons.circle,
                  text: mision.estado,
                  color: _colorEstado(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _Tag({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tagColor = color ?? const Color(0xFF8B6F47);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: tagColor,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: tagColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}