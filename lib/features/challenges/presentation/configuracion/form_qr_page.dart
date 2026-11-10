
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/desafio_form_header.dart';
import '../widgets/desafio_form_card.dart';
import '../widgets/desafio_form_field.dart';

class FormQrPage extends StatefulWidget {
  final SupabaseClient supabase;
  final String idDesafio;

  const FormQrPage({
    super.key,
    required this.supabase,
    required this.idDesafio,
  });

  @override
  State<FormQrPage> createState() => _FormQrPageState();
}

class _FormQrPageState extends State<FormQrPage> {
  final _pistaController = TextEditingController();

  List<Map<String, dynamic>> _codigos = [];
  String? _idQr;

  bool _cargando = true;
  bool _guardando = false;

  static const color = Color(0xFF9474A6);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final codigos = await widget.supabase
          .from('codigos_qr')
          .select('id_qr, ubicacion_referencia, id_objeto')
          .eq('estado', true)
          .order('ubicacion_referencia');

      final configuracion = await widget.supabase
          .from('desafio_qr_config')
          .select()
          .eq('id_desafio', widget.idDesafio)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _codigos = List<Map<String, dynamic>>.from(codigos);

        if (configuracion != null) {
          _idQr = configuracion['id_qr']?.toString();
          _pistaController.text = configuracion['pista'] ?? '';
        }

        if (_idQr != null &&
            !_codigos.any((c) => c['id_qr'].toString() == _idQr)) {
          _idQr = null;
        }
      });
    } catch (e) {
      if (mounted) _mensaje('Error al cargar códigos QR: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardar() async {
    if (_idQr == null) {
      _mensaje('Seleccioná un código QR.');
      return;
    }

    if (_pistaController.text.trim().isEmpty) {
      _mensaje('Ingresá una pista para el visitante.');
      return;
    }

    setState(() => _guardando = true);

    try {
      await widget.supabase
          .from('desafio_qr_config')
          .upsert({
        'id_desafio': widget.idDesafio,
        'id_qr': _idQr,
        'pista': _pistaController.text.trim(),
      }, onConflict: 'id_desafio');

      if (!mounted) return;

      _mensaje('Configuración QR guardada.');
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
        title: const Text('Configurar QR'),
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
            titulo: 'Escaneo QR',
            descripcion:
            'Asociá el desafío con un código instalado en el museo.',
            icono: Icons.qr_code_scanner,
            color: color,
            etiqueta: 'Exploración del museo',
          ),
          const SizedBox(height: 18),
          DesafioFormCard(
            titulo: 'Código QR',
            descripcion:
            'Seleccioná uno de los códigos disponibles.',
            icono: Icons.qr_code_2,
            color: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubicación del código',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _idQr,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: const Text('Seleccionar código QR'),
                  items: _codigos.map((codigo) {
                    final ubicacion =
                    codigo['ubicacion_referencia']?.toString();

                    return DropdownMenuItem<String>(
                      value: codigo['id_qr'].toString(),
                      child: Text(
                        ubicacion?.isNotEmpty == true
                            ? ubicacion!
                            : 'Código sin ubicación',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => _idQr = v);
                  },
                  validator: (v) =>
                  v == null ? 'Seleccioná un QR' : null,
                ),
                if (_codigos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'No hay códigos QR activos disponibles. '
                          'Primero registrá un código para este museo.',
                      style: TextStyle(
                        color: Color(0xFF8A4B42),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          DesafioFormCard(
            titulo: 'Pista para el visitante',
            descripcion:
            'Escribí una indicación que ayude a encontrar el código.',
            icono: Icons.lightbulb_outline,
            color: color,
            child: DesafioFormField(
              label: 'Pista',
              controller: _pistaController,
              hint: 'Ej. Buscá cerca de la entrada de la sala...',
              maxLines: 4,
              required: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _guardando || _codigos.isEmpty
                  ? null
                  : _guardar,
              icon: const Icon(Icons.save_outlined),
              label: Text(
                _guardando
                    ? 'Guardando...'
                    : 'Guardar configuración',
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
    _pistaController.dispose();
    super.dispose();
  }
}
