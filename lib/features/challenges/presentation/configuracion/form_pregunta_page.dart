
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/desafio_form_header.dart';
import '../widgets/desafio_form_card.dart';
import '../widgets/desafio_form_field.dart';

class FormPreguntaPage extends StatefulWidget {
  final SupabaseClient supabase;
  final String idDesafio;

  const FormPreguntaPage({
    super.key,
    required this.supabase,
    required this.idDesafio,
  });

  @override
  State<FormPreguntaPage> createState() => _FormPreguntaPageState();
}

class _FormPreguntaPageState extends State<FormPreguntaPage> {
  final List<TextEditingController> _opciones =
  List.generate(4, (_) => TextEditingController());

  int? _correcta;
  bool _cargando = true;
  bool _guardando = false;

  static const color = Color(0xFF547B9B);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final datos = await widget.supabase
          .from('desafio_opciones')
          .select()
          .eq('id_desafio', widget.idDesafio)
          .order('orden');

      if (!mounted) return;

      for (int i = 0; i < datos.length && i < 4; i++) {
        _opciones[i].text = datos[i]['texto'] ?? '';

        if (datos[i]['es_correcta'] == true) {
          _correcta = i;
        }
      }
    } catch (e) {
      if (mounted) _mensaje('Error al cargar opciones: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardar() async {
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
      // Reemplazar las alternativas anteriores.
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

      _mensaje('Pregunta configurada correctamente.');
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        _mensaje('No se pudo guardar: $e');
      }
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
        title: const Text('Configurar pregunta'),
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
            titulo: 'Configurar pregunta',
            descripcion:
            'Definí las alternativas que tendrá que responder el visitante.',
            icono: Icons.quiz_outlined,
            color: color,
            etiqueta: 'Desafío de conocimiento',
          ),
          const SizedBox(height: 18),
          DesafioFormCard(
            titulo: 'Alternativas',
            descripcion:
            'Ingresá cuatro respuestas y seleccioná la correcta.',
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
        label: Text(_guardando ? 'Guardando...' : 'Guardar pregunta'),
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
    for (final controller in _opciones) {
      controller.dispose();
    }
    super.dispose();
  }
}
