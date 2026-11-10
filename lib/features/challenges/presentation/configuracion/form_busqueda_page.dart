
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/desafio_form_header.dart';
import '../widgets/desafio_form_card.dart';
import '../widgets/desafio_form_field.dart';

class FormBusquedaPage extends StatefulWidget {
  final SupabaseClient supabase;
  final String idDesafio;

  const FormBusquedaPage({
    super.key,
    required this.supabase,
    required this.idDesafio,
  });

  @override
  State<FormBusquedaPage> createState() => _FormBusquedaPageState();
}

class _FormBusquedaPageState extends State<FormBusquedaPage> {
  final _referenciaController = TextEditingController();
  final _etiquetasController = TextEditingController();

  double _umbral = 0.75;

  bool _cargando = true;
  bool _guardando = false;

  static const color = Color(0xFF66866A);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final datos = await widget.supabase
          .from('desafio_busqueda_config')
          .select()
          .eq('id_desafio', widget.idDesafio)
          .maybeSingle();

      if (datos != null) {
        _referenciaController.text =
            datos['descripcion_referencia'] ?? '';

        final etiquetas =
        List<String>.from(datos['etiquetas_esperadas'] ?? []);

        _etiquetasController.text = etiquetas.join(', ');

        _umbral = (datos['umbral_confianza'] as num?)?.toDouble() ?? 0.75;
      }
    } catch (e) {
      if (mounted) _mensaje('Error al cargar configuración: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardar() async {
    if (_referenciaController.text.trim().isEmpty) {
      _mensaje('Ingresá una descripción de referencia.');
      return;
    }

    final etiquetas = _etiquetasController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    if (etiquetas.isEmpty) {
      _mensaje('Ingresá al menos una etiqueta.');
      return;
    }

    setState(() => _guardando = true);

    try {
      await widget.supabase
          .from('desafio_busqueda_config')
          .upsert({
        'id_desafio': widget.idDesafio,
        'descripcion_referencia': _referenciaController.text.trim(),
        'etiquetas_esperadas': etiquetas,
        'umbral_confianza': _umbral,
      }, onConflict: 'id_desafio');

      if (!mounted) return;

      _mensaje('Configuración guardada.');
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
        title: const Text('Configurar búsqueda'),
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
            titulo: 'Búsqueda de objeto',
            descripcion:
            'Configurá qué objeto deberá encontrar y fotografiar el visitante.',
            icono: Icons.camera_alt_outlined,
            color: color,
            etiqueta: 'Reconocimiento visual',
          ),
          const SizedBox(height: 18),
          DesafioFormCard(
            titulo: 'Objeto esperado',
            descripcion:
            'Indicá qué debe reconocer el sistema de inteligencia artificial.',
            icono: Icons.image_search_outlined,
            color: color,
            child: Column(
              children: [
                DesafioFormField(
                  label: 'Descripción de referencia',
                  controller: _referenciaController,
                  hint: 'Ej. Una vasija de cerámica antigua',
                  maxLines: 3,
                  required: true,
                ),
                const SizedBox(height: 18),
                DesafioFormField(
                  label: 'Etiquetas esperadas',
                  controller: _etiquetasController,
                  hint: 'vasija, cerámica, recipiente',
                  helperText:
                  'Separá las etiquetas mediante comas.',
                  required: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          DesafioFormCard(
            titulo: 'Validación de IA',
            descripcion:
            'Definí la confianza mínima requerida para aceptar una fotografía.',
            icono: Icons.tune,
            color: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Umbral de confianza: ${(_umbral * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: _umbral,
                  min: 0.50,
                  max: 0.99,
                  divisions: 49,
                  activeColor: color,
                  onChanged: (v) {
                    setState(() => _umbral = v);
                  },
                ),
                const Text(
                  'Un umbral más alto exige mayor coincidencia con el objeto esperado.',
                  style: TextStyle(
                    color: Color(0xFF777168),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _botonGuardar(),
        ],
      ),
    );
  }

  Widget _botonGuardar() {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _guardando ? null : _guardar,
        icon: const Icon(Icons.save_outlined),
        label: Text(_guardando ? 'Guardando...' : 'Guardar configuración'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF292621),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _referenciaController.dispose();
    _etiquetasController.dispose();
    super.dispose();
  }
}
