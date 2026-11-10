
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'form_desafio_page.dart';
import '../models/desafio_museo.dart';
import '../services/desafio_completoservice.dart';
import '../services/desafio_service.dart';
import 'form_desafio_page.dart';

class GestionarDesafiosPage extends StatefulWidget {
  final SupabaseClient supabase;

  const GestionarDesafiosPage({
    super.key,
    required this.supabase,
  });

  @override
  State<GestionarDesafiosPage> createState() =>
      _GestionarDesafiosPageState();
}

class _GestionarDesafiosPageState
    extends State<GestionarDesafiosPage> {
  late final DesafioService _service;

  List<Map<String, dynamic>> _misiones = [];
  List<DesafioMuseo> _desafios = [];

  String? _misionSeleccionada;

  bool _cargando = true;


  IconData _iconoTipo(TipoDesafio tipo) {
    switch (tipo) {
      case TipoDesafio.pregunta:
        return Icons.quiz_outlined;

      case TipoDesafio.busquedaObjeto:
        return Icons.camera_alt_outlined;

      case TipoDesafio.escaneoQr:
        return Icons.qr_code_scanner;

      case TipoDesafio.identificacion:
        return Icons.image_search_outlined;
    }
  }

  Color _colorTipo(TipoDesafio tipo) {
    switch (tipo) {
      case TipoDesafio.pregunta:
        return const Color(0xFF547B9B);

      case TipoDesafio.busquedaObjeto:
        return const Color(0xFF66866A);

      case TipoDesafio.escaneoQr:
        return const Color(0xFF9474A6);

      case TipoDesafio.identificacion:
        return const Color(0xFFB47C48);
    }
  }



  @override
  void initState() {
    super.initState();
    _service = DesafioService(widget.supabase);
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      final misiones = await _service.listarMisiones();

      if (!mounted) return;

      setState(() {
        _misiones = misiones;
        _misionSeleccionada = null;
      });

      await _cargarDesafios();
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargando = false);
      _mensaje('Error al cargar misiones: $e');
    }
  }

  Future<void> _cargarDesafios() async {
    setState(() => _cargando = true);

    try {
      final desafios = _misionSeleccionada == null
          ? await _service.listarTodos()
          : await _service.listarPorMision(
        _misionSeleccionada!,
      );

      if (!mounted) return;

      setState(() {
        _desafios = desafios;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargando = false);
      _mensaje('Error al cargar desafíos: $e');
    }
  }


  Future<void> _crear() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormDesafioPage(
          supabase: widget.supabase,
          idMisionInicial: _misionSeleccionada,
        ),
      ),
    );

    if (resultado == true && mounted) {
      await _cargarDesafios();
    }
  }


  Future<void> _editar(DesafioMuseo desafio) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormDesafioPage(
          supabase: widget.supabase,
          desafio: desafio,
        ),
      ),
    );

    if (resultado == true && mounted) {
      await _cargarDesafios();
    }
  }

  Future<void> _cambiarEstado(DesafioMuseo desafio) async {
    try {
      await _service.cambiarEstado(
        desafio.idDesafio,
        !desafio.estado,
      );

      await _cargarDesafios();

      _mensaje(
        desafio.estado
            ? 'Desafío desactivado.'
            : 'Desafío activado.',
      );
    } catch (e) {
      _mensaje('No se pudo cambiar el estado: $e');
    }
  }

  Future<void> _eliminar(DesafioMuseo desafio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar desafío'),
        content: Text(
          '¿Querés eliminar definitivamente '
              '"${desafio.titulo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await _service.eliminar(desafio.idDesafio);
      await _cargarDesafios();
      _mensaje('Desafío eliminado.');
    } catch (e) {
      _mensaje('No se pudo eliminar el desafío: $e');
    }
  }

  String _nombreMision(String idMision) {
    final coincidencias = _misiones.where(
          (m) => m['id_mision'].toString() == idMision,
    );

    if (coincidencias.isEmpty) {
      return 'Misión desconocida';
    }

    return coincidencias.first['nombre'].toString();
  }

  void _mensaje(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const fondo = Color(0xFFF5EFE6);
    const texto = Color(0xFF292621);
    const acento = Color(0xFF8B6F47);

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('Gestionar desafíos'),
        backgroundColor: fondo,
        foregroundColor: texto,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargarDesafios,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _misiones.isEmpty ? null : _crear,
        backgroundColor: acento,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo desafío'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DropdownButtonFormField<String?>(
              value: _misionSeleccionada,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Filtrar por misión',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFF9F6F0),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todas las misiones'),
                ),
                ..._misiones.map((m) {
                  return DropdownMenuItem<String?>(
                    value: m['id_mision'].toString(),
                    child: Text(m['nombre'].toString()),
                  );
                }),
              ],
              onChanged: (value) async {
                setState(() {
                  _misionSeleccionada = value;
                });
                await _cargarDesafios();
              },
            ),
          ),

          Expanded(
            child: _cargando
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _misiones.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Todavía no hay misiones. '
                      'Creá una misión antes de agregar desafíos.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
                : _desafios.isEmpty
                ? const Center(
              child: Text(
                'No hay desafíos para mostrar.',
              ),
            )
                : RefreshIndicator(
              onRefresh: _cargarDesafios,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  16, 8, 16, 100,
                ),
                itemCount: _desafios.length,
                itemBuilder: (context, index) {
                  final desafio = _desafios[index];

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    color: const Color(0xFFF9F6F0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                      side: const BorderSide(
                        color: Color(0xFFD6CEC2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: _colorTipo(desafio.tipo).withValues(alpha: 0.15),
                                foregroundColor: _colorTipo(desafio.tipo),
                                child: Icon(_iconoTipo(desafio.tipo)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      desafio.titulo,
                                      style: const TextStyle(
                                        color: texto,
                                        fontSize: 16,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _nombreMision(
                                        desafio.idMision,
                                      ),
                                      style: const TextStyle(
                                        color: acento,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (accion) {
                                  switch (accion) {
                                    case 'editar':
                                      _editar(desafio);
                                      break;
                                    case 'estado':
                                      _cambiarEstado(desafio);
                                      break;
                                    case 'eliminar':
                                      _eliminar(desafio);
                                      break;
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'editar',
                                    child: Text('Editar'),
                                  ),
                                  PopupMenuItem(
                                    value: 'estado',
                                    child: Text(
                                      desafio.estado
                                          ? 'Desactivar'
                                          : 'Activar',
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'eliminar',
                                    child: Text('Eliminar'),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            desafio.descripcion,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF756F68),
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _etiqueta(
                                desafio.tipo.etiqueta,
                              ),
                              _etiqueta(
                                '${desafio.puntos} puntos',
                              ),
                              _etiqueta(
                                '${desafio.cantidadMaxIntentos} intentos',
                              ),
                              _etiqueta(
                                desafio.estado
                                    ? 'Activo'
                                    : 'Inactivo',
                                activo: desafio.estado,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

      Widget _etiqueta(
      String texto, {
      bool activo = true,
      Color? color,
      }) {
      final Color colorBase = color ??
      (activo
      ? const Color(0xFF6D5637)
      : const Color(0xFF8A4B42));

      return Container(
      padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
      ),
      decoration: BoxDecoration(
      color: colorBase.withValues(alpha: 0.13),
      borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
      texto,
      style: TextStyle(
      color: colorBase,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      ),
      ),
      );
      }}