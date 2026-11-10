
import 'configuracion/form_pregunta_page.dart';
import 'configuracion/form_busqueda_page.dart';
import 'configuracion/form_qr_page.dart';
import 'configuracion/form_identificacion_page.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/desafio_museo.dart';
import '../services/desafio_service.dart';

class FormDesafioPage extends StatefulWidget {
  final SupabaseClient supabase;
  final DesafioMuseo? desafio;
  final String? idMisionInicial;

  const FormDesafioPage({
    super.key,
    required this.supabase,
    this.desafio,
    this.idMisionInicial,
  });

  @override
  State<FormDesafioPage> createState() =>
      _FormDesafioPageState();
}

class _FormDesafioPageState extends State<FormDesafioPage> {
  final _formKey = GlobalKey<FormState>();

  late final DesafioService _service;

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ordenController = TextEditingController();
  final _puntosController = TextEditingController();
  final _intentosController = TextEditingController();

  List<Map<String, dynamic>> _misiones = [];

  String? _idMision;

  TipoDesafio _tipo = TipoDesafio.pregunta;

  bool _permitirReintento = true;
  bool _estado = true;
  bool _cargando = true;
  bool _guardando = false;

  bool get _esEdicion => widget.desafio != null;

  static const Color fondo = Color(0xFFF5EFE6);
  static const Color texto = Color(0xFF292621);
  static const Color acento = Color(0xFF8B6F47);

  @override
  void initState() {
    super.initState();

    _service = DesafioService(widget.supabase);

    final d = widget.desafio;

    if (d != null) {
      _tituloController.text = d.titulo;
      _descripcionController.text = d.descripcion;
      _ordenController.text = d.orden.toString();
      _puntosController.text = d.puntos.toString();
      _intentosController.text =
          d.cantidadMaxIntentos.toString();

      _idMision = d.idMision;
      _tipo = d.tipo;
      _permitirReintento = d.permitirReintento;
      _estado = d.estado;
    } else {
      _idMision = widget.idMisionInicial;
      _ordenController.text = '1';
      _puntosController.text = '10';
      _intentosController.text = '3';
    }

    _cargarMisiones();
  }

  Future<void> _abrirConfiguracion(
      String idDesafio,
      TipoDesafio tipo,
      ) async {
    final Widget pagina;

    switch (tipo) {
      case TipoDesafio.pregunta:
        pagina = FormPreguntaPage(
          supabase: widget.supabase,
          idDesafio: idDesafio,
        );
        break;

      case TipoDesafio.busquedaObjeto:
        pagina = FormBusquedaPage(
          supabase: widget.supabase,
          idDesafio: idDesafio,
        );
        break;

      case TipoDesafio.escaneoQr:
        pagina = FormQrPage(
          supabase: widget.supabase,
          idDesafio: idDesafio,
        );
        break;

      case TipoDesafio.identificacion:
        pagina = FormIdentificacionPage(
          supabase: widget.supabase,
          idDesafio: idDesafio,
        );
        break;
    }

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => pagina,
      ),
    );
  }

  Future<void> _cargarMisiones() async {
    try {
      final misiones = await _service.listarMisiones();

      if (!mounted) return;

      setState(() {
        _misiones = misiones;

        final ids = misiones
            .map((m) => m['id_mision'].toString())
            .toSet();

        if (_idMision == null || !ids.contains(_idMision)) {
          _idMision = null;
        }

        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargando = false);
      _mensaje('Error al cargar misiones: $e');
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_idMision == null) {
      _mensaje('Seleccioná una misión.');
      return;
    }

    setState(() => _guardando = true);

    try {
      final desafio = DesafioMuseo(
        idDesafio: widget.desafio?.idDesafio ?? '',
        idMision: _idMision!,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        tipo: _tipo,
        orden: int.parse(_ordenController.text.trim()),
        puntos: int.parse(_puntosController.text.trim()),
        cantidadMaxIntentos:
        int.parse(_intentosController.text.trim()),
        permitirReintento: _permitirReintento,
        estado: _estado,
      );

      late final String idDesafio;

      if (_esEdicion) {
        await _service.actualizar(desafio);
        idDesafio = widget.desafio!.idDesafio;
      } else {
        idDesafio = await _service.crear(desafio);
      }

      if (!mounted) return;

      await _abrirConfiguracion(idDesafio, _tipo);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _mensaje('No se pudo guardar el desafío: $e');
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  void _mensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  String _nombreTipo(TipoDesafio tipo) {
    switch (tipo) {
      case TipoDesafio.pregunta:
        return 'Pregunta';
      case TipoDesafio.busquedaObjeto:
        return 'Búsqueda de objeto';
      case TipoDesafio.escaneoQr:
        return 'Escaneo QR';
      case TipoDesafio.identificacion:
        return 'Identificación';
    }
  }

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

  Widget _campo({
    required String etiqueta,
    required TextEditingController controller,
    required String? Function(String?) validator,
    String? ayuda,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            color: texto,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: texto),
          decoration: InputDecoration(
            hintText: ayuda,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD6CEC2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD6CEC2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: acento,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _seccion({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DED3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: acento, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: texto,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            descripcion,
            style: const TextStyle(
              color: Color(0xFF777168),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _selectorTipo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de desafío',
          style: TextStyle(
            color: texto,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<TipoDesafio>(
          value: _tipo,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: TipoDesafio.values.map((tipo) {
            return DropdownMenuItem(
              value: tipo,
              child: Row(
                children: [
                  Icon(_iconoTipo(tipo), color: acento, size: 20),
                  const SizedBox(width: 10),
                  Text(_nombreTipo(tipo)),
                ],
              ),
            );
          }).toList(),
          onChanged: _esEdicion
              ? null
              : (tipo) {
            if (tipo == null) return;
            setState(() => _tipo = tipo);
          },
        ),
        if (_esEdicion)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'El tipo no puede modificarse después de crear el desafío.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF777168),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: fondo,
        foregroundColor: texto,
        elevation: 0,
        title: Text(
          _esEdicion ? 'Editar desafío' : 'Nuevo desafío',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _seccion(
              titulo: 'Información general',
              descripcion:
              'Definí los datos principales del desafío.',
              icono: Icons.description_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Misión asociada',
                    style: TextStyle(
                      color: texto,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _idMision,
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: const Text('Seleccionar misión'),
                    items: _misiones.map((m) {
                      return DropdownMenuItem<String>(
                        value: m['id_mision'].toString(),
                        child: Text(m['nombre'].toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _idMision = value);
                    },
                    validator: (value) =>
                    value == null ? 'Seleccioná una misión' : null,
                  ),
                  const SizedBox(height: 18),
                  _campo(
                    etiqueta: 'Título',
                    controller: _tituloController,
                    ayuda: 'Ej. Identificá una pieza histórica',
                    validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Ingresá un título'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  _campo(
                    etiqueta: 'Descripción',
                    controller: _descripcionController,
                    ayuda: 'Explicá qué debe realizar el visitante',
                    maxLines: 4,
                    validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Ingresá una descripción'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  _selectorTipo(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _seccion(
              titulo: 'Puntuación y reglas',
              descripcion:
              'Establecé las condiciones para completar el desafío.',
              icono: Icons.stars_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _campo(
                          etiqueta: 'Orden',
                          controller: _ordenController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            return n == null || n < 1
                                ? 'Orden inválido'
                                : null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _campo(
                          etiqueta: 'Puntos',
                          controller: _puntosController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            return n == null || n < 0
                                ? 'Puntos inválidos'
                                : null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _campo(
                    etiqueta: 'Cantidad máxima de intentos',
                    controller: _intentosController,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n == null || n < 1
                          ? 'Ingresá al menos un intento'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: acento,
                    title: const Text(
                      'Permitir reintentos',
                      style: TextStyle(
                        color: texto,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Permite volver a intentar el desafío.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _permitirReintento,
                    onChanged: (v) {
                      setState(() => _permitirReintento = v);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: acento,
                    title: const Text(
                      'Desafío activo',
                      style: TextStyle(
                        color: texto,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Determina si estará disponible para visitantes.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _estado,
                    onChanged: (v) {
                      setState(() => _estado = v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _guardando
                      ? 'Guardando...'
                      : 'Guardar desafío',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF292621),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ordenController.dispose();
    _puntosController.dispose();
    _intentosController.dispose();
    super.dispose();
  }
}
