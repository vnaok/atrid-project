import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Object.dart';
import '../services/ObjectService.dart';

class FormObjetoPage extends StatefulWidget {
  final String museoId;
  final Object? objeto;

  const FormObjetoPage({
    super.key,
    required this.museoId,
    this.objeto,
  });

  @override
  State<FormObjetoPage> createState() => _FormObjetoPageState();
}

class _FormObjetoPageState extends State<FormObjetoPage> {
  late final ObjetoService _objetoService;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _historiaController;
  late final TextEditingController _codigoController;
  late final TextEditingController _ubicacionController;

  XFile? _foto;

  bool _estado = true;
  bool _guardando = false;

  bool get _modoEdicion => widget.objeto != null;

  @override
  void initState() {
    super.initState();

    _objetoService = ObjetoService(
      Supabase.instance.client,
    );

    final objeto = widget.objeto;

    _nombreController = TextEditingController(
      text: objeto?.nombre ?? '',
    );

    _descripcionController = TextEditingController(
      text: objeto?.descripcion ?? '',
    );

    _historiaController = TextEditingController(
      text: objeto?.informacionHistorica ?? '',
    );

    _codigoController = TextEditingController(
      text: objeto?.codigoIdentificador ?? '',
    );

    _ubicacionController = TextEditingController(
      text: objeto?.ubicacion ?? '',
    );

    _estado = objeto?.estado ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _historiaController.dispose();
    _codigoController.dispose();
    _ubicacionController.dispose();

    super.dispose();
  }

  // ==========================================
  // TOMAR FOTOGRAFÍA
  // ==========================================

  Future<void> _tomarFotografia() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (!mounted || foto == null) return;

      setState(() {
        _foto = foto;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir la cámara: $e'),
        ),
      );
    }
  }

  // ==========================================
  // SELECCIONAR FOTOGRAFÍA DE LA GALERÍA
  // ==========================================

  Future<void> _seleccionarFotografia() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (!mounted || foto == null) return;

      setState(() {
        _foto = foto;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo seleccionar la imagen: $e'),
        ),
      );
    }
  }

  // ==========================================
  // GUARDAR OBJETO
  // ==========================================

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      // Si hay una foto nueva, la subimos a Storage.
      // Si no, conservamos la ruta de la imagen anterior.
      String? rutaImagen = widget.objeto?.imagen;

      if (_foto != null) {
        rutaImagen = await _objetoService.subirImagen(
          museoId: widget.museoId,
          imagen: File(_foto!.path),
        );
      }

      if (_modoEdicion) {
        await _objetoService.actualizarObjeto(
          idObjeto: widget.objeto!.idObjeto,
          nombre: _nombreController.text.trim(),
          descripcion: _textoOpcional(
            _descripcionController.text,
          ),
          informacionHistorica: _textoOpcional(
            _historiaController.text,
          ),
          imagen: rutaImagen,
          codigoIdentificador:
          _codigoController.text.trim(),
          ubicacion: _textoOpcional(
            _ubicacionController.text,
          ),
          estado: _estado,
        );
      } else {
        await _objetoService.crearObjeto(
          museoId: widget.museoId,
          nombre: _nombreController.text.trim(),
          descripcion: _textoOpcional(
            _descripcionController.text,
          ),
          informacionHistorica: _textoOpcional(
            _historiaController.text,
          ),
          imagen: rutaImagen,
          codigoIdentificador:
          _codigoController.text.trim(),
          ubicacion: _textoOpcional(
            _ubicacionController.text,
          ),
          estado: _estado,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _modoEdicion
                ? 'Objeto actualizado correctamente'
                : 'Objeto creado correctamente',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error guardando objeto: $e'),
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

  // ==========================================
  // TEXTO OPCIONAL
  // ==========================================

  String? _textoOpcional(String texto) {
    final valor = texto.trim();

    return valor.isEmpty ? null : valor;
  }

  // ==========================================
  // VISTA PREVIA DE LA FOTOGRAFÍA
  // ==========================================

  Widget _construirVistaPrevia() {
    if (_foto != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(_foto!.path),
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_modoEdicion &&
        widget.objeto?.imagen != null &&
        widget.objeto!.imagen!.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
            ),
            SizedBox(height: 8),
            Text('Este objeto ya tiene una imagen'),
            Text(
              'Tomá otra foto para reemplazarla.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: 54,
          ),
          SizedBox(height: 8),
          Text('No se seleccionó ninguna fotografía'),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modoEdicion ? 'Editar objeto' : 'Nuevo objeto',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // NOMBRE
              TextFormField(
                controller: _nombreController,
                enabled: !_guardando,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Ingrese el nombre del objeto';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // CÓDIGO
              TextFormField(
                controller: _codigoController,
                enabled: !_guardando,
                decoration: const InputDecoration(
                  labelText: 'Código identificador',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Ingrese el código identificador';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // DESCRIPCIÓN
              TextFormField(
                controller: _descripcionController,
                enabled: !_guardando,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              // INFORMACIÓN HISTÓRICA
              TextFormField(
                controller: _historiaController,
                enabled: !_guardando,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Información histórica',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 24),

              // FOTOGRAFÍA
              Text(
                'Fotografía del objeto',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),

              const SizedBox(height: 12),

              _construirVistaPrevia(),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed:
                _guardando ? null : _tomarFotografia,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar fotografía'),
              ),

              OutlinedButton.icon(
                onPressed: _guardando
                    ? null
                    : _seleccionarFotografia,
                icon: const Icon(Icons.photo_library),
                label: const Text(
                  'Seleccionar de la galería',
                ),
              ),

              if (_foto != null) ...[
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: _guardando
                      ? null
                      : () {
                    setState(() {
                      _foto = null;
                    });
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(
                    'Descartar fotografía nueva',
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // UBICACIÓN
              TextFormField(
                controller: _ubicacionController,
                enabled: !_guardando,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  hintText: 'Ej. Sala 2 - Vitrina 4',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // ESTADO
              SwitchListTile(
                title: const Text('Objeto activo'),
                subtitle: const Text(
                  'Los objetos inactivos no se mostrarán '
                      'al visitante.',
                ),
                value: _estado,
                onChanged: _guardando
                    ? null
                    : (value) {
                  setState(() {
                    _estado = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // GUARDAR
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _guardando
                        ? 'Guardando...'
                        : 'Guardar objeto',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}