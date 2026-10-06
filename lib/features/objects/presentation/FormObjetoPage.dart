import 'package:flutter/material.dart';
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
  State<FormObjetoPage> createState() =>
      _FormObjetoPageState();
}

class _FormObjetoPageState
    extends State<FormObjetoPage> {

  late final ObjetoService _objetoService;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _historiaController;
  late final TextEditingController _imagenController;
  late final TextEditingController _codigoController;
  late final TextEditingController _ubicacionController;

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

    _imagenController = TextEditingController(
      text: objeto?.imagen ?? '',
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
    _imagenController.dispose();
    _codigoController.dispose();
    _ubicacionController.dispose();

    super.dispose();
  }

  // ==========================================
  // GUARDAR
  // ==========================================

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
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
          imagen: _textoOpcional(
            _imagenController.text,
          ),
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
          imagen: _textoOpcional(
            _imagenController.text,
          ),
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
          content: Text(
            'Error guardando objeto: $e',
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

  String? _textoOpcional(String texto) {
    final valor = texto.trim();

    if (valor.isEmpty) {
      return null;
    }

    return valor;
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modoEdicion
              ? 'Editar objeto'
              : 'Nuevo objeto',
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
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

              TextFormField(
                controller: _codigoController,
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

              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _historiaController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Información histórica',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _imagenController,
                decoration: const InputDecoration(
                  labelText: 'Imagen',
                  hintText: 'URL de la imagen',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  hintText: 'Ej. Sala 2 - Vitrina 4',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Objeto activo'),
                subtitle: const Text(
                  'Los objetos inactivos no se mostrarán al visitante.',
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