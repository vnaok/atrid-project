import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Object.dart';
import '../services/ObjectService.dart';
import 'FormObjetoPage.dart';

class GestionarObjetosPage extends StatefulWidget {
  final String museoId;

  const GestionarObjetosPage({
    super.key,
    required this.museoId,
  });

  @override
  State<GestionarObjetosPage> createState() =>
      _GestionarObjetosPageState();
}

class _GestionarObjetosPageState
    extends State<GestionarObjetosPage> {

  late final ObjetoService _objetoService;

  List<Object> _objetos = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _objetoService = ObjetoService(
      Supabase.instance.client,
    );

    _cargarObjetos();
  }

  // ==========================================
  // CARGAR OBJETOS
  // ==========================================

  Future<void> _cargarObjetos() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final objetos = await _objetoService.obtenerObjetos(
        widget.museoId,
      );

      if (!mounted) return;

      setState(() {
        _objetos = objetos;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ==========================================
  // CREAR
  // ==========================================

  Future<void> _crearObjeto() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormObjetoPage(
          museoId: widget.museoId,
        ),
      ),
    );

    if (resultado == true) {
      _cargarObjetos();
    }
  }

  // ==========================================
  // EDITAR
  // ==========================================

  Future<void> _editarObjeto(Object objeto) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormObjetoPage(
          museoId: widget.museoId,
          objeto: objeto,
        ),
      ),
    );

    if (resultado == true) {
      _cargarObjetos();
    }
  }

  // ==========================================
  // ELIMINAR
  // ==========================================

  Future<void> _eliminarObjeto(Object objeto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar objeto'),
          content: Text(
            '¿Está seguro de eliminar "${objeto.nombre}"?',
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
      await _objetoService.eliminarObjeto(
        objeto.idObjeto,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Objeto eliminado correctamente'),
        ),
      );

      _cargarObjetos();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo eliminar el objeto: $e',
          ),
        ),
      );
    }
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar objetos'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearObjeto,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo objeto'),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'No se pudieron cargar los objetos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarObjetos,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_objetos.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargarObjetos,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.museum_outlined,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay objetos registrados.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarObjetos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _objetos.length,
        itemBuilder: (context, index) {
          final objeto = _objetos[index];

          return _ObjetoCard(
            objeto: objeto,
            onEditar: () => _editarObjeto(objeto),
            onEliminar: () => _eliminarObjeto(objeto),
          );
        },
      ),
    );
  }
}

class _ObjetoCard extends StatelessWidget {
  final Object objeto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _ObjetoCard({
    required this.objeto,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
              child: const Icon(
                Icons.museum_outlined,
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
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    objeto.codigoIdentificador,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),

                  if (objeto.ubicacion != null &&
                      objeto.ubicacion!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Ubicación: ${objeto.ubicacion}',
                    ),
                  ],

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        objeto.estado
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        objeto.estado
                            ? 'Activo'
                            : 'Inactivo',
                      ),
                    ],
                  ),
                ],
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
      ),
    );
  }
}