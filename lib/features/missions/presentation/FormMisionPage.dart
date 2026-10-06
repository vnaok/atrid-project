import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Mission.dart';
import '../services/MissionService.dart';

class FormMisionPage extends StatefulWidget {
  final String museoId;
  final Mission? mision;

  const FormMisionPage({
    super.key,
    required this.museoId,
    this.mision,
  });

  bool get esEdicion => mision != null;

  @override
  State<FormMisionPage> createState() => _FormMisionPageState();
}

class _FormMisionPageState extends State<FormMisionPage> {

  late final MissionService _misionService;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _imagenController;
  late final TextEditingController _duracionController;

  String _dificultad = 'facil';
  String _estado = 'borrador';

  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    _misionService = MissionService(
      Supabase.instance.client,
    );

    final mision = widget.mision;

    _nombreController = TextEditingController(
      text: mision?.nombre ?? '',
    );

    _descripcionController = TextEditingController(
      text: mision?.descripcion ?? '',
    );

    _imagenController = TextEditingController(
      text: mision?.imagen ?? '',
    );

    _duracionController = TextEditingController(
      text: mision?.duracionEstimada?.toString() ?? '',
    );

    if (mision != null) {
      _dificultad = mision.dificultad;
      _estado = mision.estado;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _imagenController.dispose();
    _duracionController.dispose();

    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final duracionTexto = _duracionController.text.trim();

      final duracion = duracionTexto.isEmpty
          ? null
          : int.tryParse(duracionTexto);

      if (duracionTexto.isNotEmpty && duracion == null) {
        throw Exception(
          'La duración debe ser un número entero.',
        );
      }

      if (widget.esEdicion) {
        await _misionService.actualizarMision(
          idMision: widget.mision!.idMision,
          nombre: _nombreController.text.trim(),
          descripcion: _descripcionController.text.trim().isEmpty
              ? null
              : _descripcionController.text.trim(),
          imagen: _imagenController.text.trim().isEmpty
              ? null
              : _imagenController.text.trim(),
          duracionEstimada: duracion,
          dificultad: _dificultad,
          estado: _estado,
        );
      } else {
        await _misionService.crearMision(
          museoId: widget.museoId,
          nombre: _nombreController.text.trim(),
          descripcion: _descripcionController.text.trim().isEmpty
              ? null
              : _descripcionController.text.trim(),
          imagen: _imagenController.text.trim().isEmpty
              ? null
              : _imagenController.text.trim(),
          duracionEstimada: duracion,
          dificultad: _dificultad,
          estado: _estado,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.esEdicion
                ? 'Misión actualizada correctamente.'
                : 'Misión creada correctamente.',
          ),
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      debugPrint('ERROR GUARDANDO MISION: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar la misión: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
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
        title: Text(
          widget.esEdicion
              ? 'Editar misión'
              : 'Nueva misión',
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _campo(
                  controller: _nombreController,
                  label: 'Nombre',
                  hint: 'Nombre de la misión',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el nombre de la misión.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _campo(
                  controller: _descripcionController,
                  label: 'Descripción',
                  hint: 'Descripción de la misión',
                  maxLines: 4,
                ),

                const SizedBox(height: 16),

                _campo(
                  controller: _imagenController,
                  label: 'Imagen',
                  hint: 'URL de la imagen',
                ),

                const SizedBox(height: 16),

                _campo(
                  controller: _duracionController,
                  label: 'Duración estimada',
                  hint: 'Ejemplo: 20',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _dificultad,
                  decoration: _decoration(
                    'Dificultad',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'facil',
                      child: Text('Fácil'),
                    ),
                    DropdownMenuItem(
                      value: 'media',
                      child: Text('Media'),
                    ),
                    DropdownMenuItem(
                      value: 'dificil',
                      child: Text('Difícil'),
                    ),
                  ],
                  onChanged: _guardando
                      ? null
                      : (value) {
                    if (value != null) {
                      setState(() {
                        _dificultad = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _estado,
                  decoration: _decoration(
                    'Estado',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'borrador',
                      child: Text('Borrador'),
                    ),
                    DropdownMenuItem(
                      value: 'publicada',
                      child: Text('Publicada'),
                    ),
                    DropdownMenuItem(
                      value: 'archivada',
                      child: Text('Archivada'),
                    ),
                  ],
                  onChanged: _guardando
                      ? null
                      : (value) {
                    if (value != null) {
                      setState(() {
                        _estado = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B6F47),
                      foregroundColor: Colors.white,
                    ),
                    child: _guardando
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      widget.esEdicion
                          ? 'Guardar cambios'
                          : 'Crear misión',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _decoration(label).copyWith(
        hintText: hint,
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
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
          color: Color(0xFF8B6F47),
          width: 2,
        ),
      ),
    );
  }
}