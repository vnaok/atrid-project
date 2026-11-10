
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/desafio_form_header.dart';
import '../widgets/desafio_form_card.dart';
import '../widgets/desafio_form_field.dart';

class FormIdentificacionPage extends StatefulWidget {
  final SupabaseClient supabase;
  final String idDesafio;

  const FormIdentificacionPage({
    super.key,
    required this.supabase,
    required this.idDesafio,
  });

  @override
  State<FormIdentificacionPage> createState() =>
      _FormIdentificacionPageState();
}

class _FormIdentificacionPageState
    extends State<FormIdentificacionPage> {
  final List<TextEditingController> _opciones =
  List.generate(4, (_) => TextEditingController());

  final _imagenController = TextEditingController();

  List<Map<String, dynamic>> _objetos = [];

  String? _idObjeto;
  String _tipoIdentificacion = 'objeto';

  int? _correcta;

  bool _cargando = true;
  bool _guardando = false;

  static const color = Color(0xFFB47C48);

  final Map<String, String> _tipos = {
    'objeto': 'Identificar el objeto',
    'epoca': 'Identificar la época',
    'material': 'Identificar el material',
    'funcion': 'Identificar la función',
    'detalle': 'Reconocer un detalle histórico',
  };

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final objetos = await widget.supabase
          .from('objetos')
          .select('id_objeto, nombre, imagen')
          .eq('estado', true)
          .order('nombre');

      final configuracion = await widget.supabase
          .from('desafio_identificacion_config')
          .select()
          .eq('id_desafio', widget.idDesafio)
          .maybeSingle();

      final opciones = await widget.supabase
          .from('desafio_opciones')
          .select()
          .eq('id_desafio', widget.idDesafio)
          .order('orden');

      if (!mounted) return;

      setState(() {
        _objetos = List<Map<String, dynamic>>.from(objetos);

        if (configuracion != null) {
          _idObjeto =
              configuracion['id_objeto_correcto']?.toString();

          _imagenController.text =
              configuracion['imagen_referencia'] ?? '';

          final tipo =
          configuracion['tipo_identificacion']?.toString();

          if (_tipos.containsKey(tipo)) {
            _tipoIdentificacion = tipo!;
          }
        }

        for (int i = 0; i < opciones.length && i < 4; i++) {
          _opciones[i].text = opciones[i]['texto'] ?? '';

          if (opciones[i]['es_correcta'] == true) {
            _correcta = i;
          }
        }

        if (_idObjeto != null &&
            !_objetos.any((o) => o['id_objeto'].toString() == _idObjeto)) {
          _idObjeto = null;
        }
      });
    } catch (e) {
      if (mounted) _mensaje('Error al cargar datos: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _seleccionarObjeto(String? id) {
    if (id == null) return;

    final objeto = _objetos.firstWhere(
          (o) => o['id_objeto'].toString() == id,
    );

    setState(() {
      _idObjeto = id;
      _imagenController.text = objeto['imagen']?.toString() ?? '';
    });
  }

  Future<void> _guardar() async {
    if (_idObjeto == null) {
      _mensaje('Seleccioná un objeto.');
      return;
    }

    if (_opciones.any((c) => c.text.trim().isEmpty)) {
      _mensaje('Completá las cuatro alternativas.');
      return;
    }

    if (_correcta == null) {
      _mensaje('Seleccioná la respuesta correcta.');
      return;
    }

    setState(() => _guardando = true);

    try {
      await widget.supabase
          .from('desafio_identificacion_config')
          .upsert({
        'id_desafio': widget.idDesafio,
        'id_objeto_correcto': _idObjeto,
        'imagen_referencia':
        _imagenController.text.trim().isEmpty
            ? null
            : _imagenController.text.trim(),
        'tipo_identificacion': _tipoIdentificacion,
      }, onConflict: 'id_desafio');

      await widget.supabase
          .from('desafio_opciones')
          .delete()
          .eq('id_desafio', widget.idDesafio);

      final datos = List.generate(4, (i) {
        return {
          'id_desafio': widget.idDesafio,
          'texto': _opciones[i].text.trim(),
          'imagen': null,
          'es_correcta': i == _correcta,
          'orden': i + 1,
        };
      });

      await widget.supabase
          .from('desafio_opciones')
          .insert(datos);

      if (!mounted) return;

      _mensaje('Identificación configurada correctamente.');
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _mensaje('No se pudo guardar: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        title: const Text('Configurar identificación'),
        backgroundColor: const Color(0xFFF5EFE6),
        foregroundColor: const Color(0xFF292621),
        elevation: 0,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const DesafioFormHeader(
            titulo: 'Identificación',
            descripcion:
            'Configurá el objeto y las respuestas que deberá reconocer el visitante.',
            icono: Icons.image_search_outlined,
            color: color,
            etiqueta: 'Reconocimiento',
          ),
          const SizedBox(height: 18),
          DesafioFormCard(
            titulo: 'Objeto de referencia',
            descripcion:
            'Seleccioná el objeto que se utilizará en el desafío.',
            icono: Icons.museum_outlined,
            color: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _idObjeto,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: const Text('Seleccionar objeto'),
                  items: _objetos.map((objeto) {
                    return DropdownMenuItem<String>(
                      value: objeto['id_objeto'].toString(),
                      child: Text(objeto['nombre'].toString()),
                    );
                  }).toList(),
                  onChanged: _seleccionarObjeto,
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  value: _tipoIdentificacion,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _tipos.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _tipoIdentificacion = v);
                    }
                  },
                ),
                const SizedBox(height: 18),
                DesafioFormField(
                  label: 'Imagen de referencia',
                  controller: _imagenController,
                  hint: 'Ruta de imagen en Supabase Storage',
                  helperText:
                  'Se completa automáticamente al seleccionar un objeto.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          DesafioFormCard(
            titulo: 'Alternativas',
            descripcion:
            'Ingresá las posibles respuestas y marcá la correcta.',
            icono: Icons.list_alt,
            color: color,
            child: Column(
              children: List.generate(4, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: _correcta,
                        activeColor: color,
                        onChanged: (v) {
                          setState(() => _correcta = v);
                        },
                      ),
                      Expanded(
                        child: DesafioFormField(
                          label: 'Alternativa ${i + 1}',
                          controller: _opciones[i],
                          hint: 'Escribí una respuesta',
                          required: true,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _guardando ||
                  _objetos.isEmpty
                  ? null
                  : _guardar,
              icon: const Icon(Icons.save_outlined),
              label: Text(
                _guardando
                    ? 'Guardando...'
                    : 'Guardar identificación',
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _opciones) {
      controller.dispose();
    }
    _imagenController.dispose();
    super.dispose();
  }
}
