
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../services/generadorimagenservice.dart';
import 'package:image_picker/image_picker.dart';
import '../models/badge.dart' as modelo;
import '../services/badgeService.dart';

class GestionarInsigniaPage extends StatefulWidget {
  final String idMuseo;
  final BadgeService badgeService;


  const GestionarInsigniaPage({
    super.key,
    required this.idMuseo,
    required this.badgeService,
  });

  @override
  State<GestionarInsigniaPage> createState() =>
      _GestionarInsigniaPageState();
}

class _GestionarInsigniaPageState
    extends State<GestionarInsigniaPage> {

  List<modelo.Badge> _insignias = [];
  late final GeneradorImagenService _generadorImagenService;

  Uint8List? _imagenGenerada;
  bool _generandoImagen = false;

  bool _cargando = true;
  String? _error;

  final Color _fondo = const Color(0xFFF5EFE6);
  final Color _texto = const Color(0xFF292621);
  final Color _acento = const Color(0xFF8B6F47);
  final Color _borde = const Color(0xFFD6CEC2);

  @override
  void initState() {
    super.initState();
    _cargarInsignias();
    _generadorImagenService = GeneradorImagenService(
     // Supabase.instance.client,
    );
  }



  // ==========================================
  // CARGAR INSIGNIAS
  // ==========================================
  Future<void> _generarImagen(String descripcion) async {
    try {
      setState(() {
        _generandoImagen = true;
        _imagenGenerada = null;
      });

      final imagen = await _generadorImagenService.generarImagen(
        descripcion: descripcion,
      );

      if (!mounted) return;

      setState(() {
        _imagenGenerada = imagen;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar imagen: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _generandoImagen = false;
        });
      }
    }
  }

  Future<void> _cargarInsignias() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado =
      await widget.badgeService.listarPorMuseo(
        widget.idMuseo,
        soloActivas: false,
      );

      if (!mounted) return;

      setState(() {
        _insignias = resultado;
        _cargando = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  // ==========================================
  // SNACKBAR
  // ==========================================

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // CONSTRUIR URL DE IMAGEN
  // ==========================================

  String? _obtenerImagenUrl(String? ruta) {
    if (ruta == null || ruta.trim().isEmpty) {
      return null;
    }

    widget.badgeService.obtenerImagenUrl(ruta.trim());
  }



  // ==========================================
  // CREAR / EDITAR INSIGNIA
  // ==========================================

  Future<void> _mostrarFormulario() async {
    final formKey = GlobalKey<FormState>();

    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final condicionController = TextEditingController();
    final puntosController = TextEditingController(text: '0');

    final ImagePicker picker = ImagePicker();

    XFile? archivoSeleccionado;
    Uint8List? imagenBytes;

    final generadorImagenService = GeneradorImagenService(
      //Supabase.instance.client,
    );

    final generadorController = TextEditingController();

    bool generandoImagen = false;
    bool estado = true;

    Future<void> generarImagenIA(
        StateSetter setDialogState,
        ) async {
      if (generadorController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escribí una descripción para generar la imagen'),
          ),
        );
        return;
      }

      try {
        setDialogState(() {
          generandoImagen = true;
        });

        final bytes = await generadorImagenService.generarImagen(
          descripcion: generadorController.text.trim(),
        );

        setDialogState(() {
          imagenBytes = bytes;
          archivoSeleccionado = null;
        });
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo generar la imagen: $e'),
          ),
        );
      } finally {
        setDialogState(() {
          generandoImagen = false;
        });
      }
    }

    try {
      final resultado = await showDialog<modelo.Badge>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: const Color(0xFFF9F6F0),
                title: const Text(
                  'Nueva insignia',
                  style: TextStyle(
                    color: Color(0xFF292621),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SizedBox(
                  width: 450,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // SELECTOR DE IMAGEN
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // SELECTOR Y PREVISUALIZACIÓN DE IMAGEN
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  try {
                                    final archivo = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 85,
                                      maxWidth: 1200,
                                    );

                                    if (archivo == null) return;

                                    final extension = archivo.name
                                        .split('.')
                                        .last
                                        .toLowerCase();

                                    if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
                                      if (!mounted) return;

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Seleccioná una imagen JPG, PNG o WEBP',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final bytes = await archivo.readAsBytes();

                                    if (bytes.length > 2 * 1024 * 1024) {
                                      if (!mounted) return;

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'La imagen no puede superar los 2 MB',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setDialogState(() {
                                      archivoSeleccionado = archivo;
                                      imagenBytes = bytes;
                                    });
                                  } catch (e) {
                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No se pudo seleccionar la imagen: $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5EFE6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFD6CEC2),
                                    ),
                                  ),
                                  child: imagenBytes != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      imagenBytes!,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                      : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 42,
                                        color: Color(0xFF8B6F47),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Seleccionar imagen',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'JPG, PNG o WEBP · Máximo 2 MB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF77716A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // NOMBRE DEL ARCHIVO SELECCIONADO
                              if (archivoSeleccionado != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        archivoSeleccionado!.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Quitar imagen',
                                      onPressed: () {
                                        setDialogState(() {
                                          archivoSeleccionado = null;
                                          imagenBytes = null;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        color: Color(0xFF8B3A3A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 16),

                              // GENERACIÓN CON IA
                              TextFormField(
                                controller: generadorController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Crear imagen con IA',
                                  hintText: 'Describí cómo querés que sea la insignia...',
                                  prefixIcon: Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFF8B6F47),
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),

                              const SizedBox(height: 10),

                              ElevatedButton.icon(
                                onPressed: generandoImagen
                                    ? null
                                    : () => generarImagenIA(setDialogState),
                                icon: generandoImagen
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Icon(Icons.auto_awesome),
                                label: Text(
                                  generandoImagen
                                      ? 'Generando imagen...'
                                      : 'Generar imagen con IA',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B6F47),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),

                              if (generandoImagen) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'La generación puede tardar varios minutos. No cierres el formulario.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF77716A),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          if (archivoSeleccionado != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    archivoSeleccionado!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Quitar imagen',
                                  onPressed: () {
                                    setDialogState(() {
                                      archivoSeleccionado = null;
                                      imagenBytes = null;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Color(0xFF8B3A3A),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 20),

                          // NOMBRE
                          TextFormField(
                            controller: nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              hintText: 'Ej. Explorador del museo',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresá un nombre';
                              }

                              if (value.trim().length > 100) {
                                return 'Máximo 100 caracteres';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // DESCRIPCIÓN
                          TextFormField(
                            controller: descripcionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                              hintText: 'Describe esta recompensa...',
                            ),
                          ),

                          const SizedBox(height: 12),

                          // CONDICIÓN
                          TextFormField(
                            controller: condicionController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Condición',
                              hintText: 'Ej. Completar 3 misiones',
                            ),
                          ),

                          const SizedBox(height: 12),

                          // PUNTOS
                          TextFormField(
                            controller: puntosController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Puntos requeridos',
                            ),
                            validator: (value) {
                              final puntos = int.tryParse(value ?? '');

                              if (puntos == null || puntos < 0) {
                                return 'Ingresá un número válido';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // ESTADO
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Insignia activa'),
                            value: estado,
                            activeThumbColor: const Color(0xFF8B6F47),
                            onChanged: (value) {
                              setDialogState(() {
                                estado = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B6F47),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      final insignia = modelo.Badge(
                        idInsignia: '',
                        idMuseo: widget.idMuseo,
                        nombre: nombreController.text.trim(),
                        descripcion:
                        descripcionController.text.trim().isEmpty
                            ? null
                            : descripcionController.text.trim(),
                        condicion:
                        condicionController.text.trim().isEmpty
                            ? null
                            : condicionController.text.trim(),
                        imagen: null,
                        puntosRequeridos:
                        int.parse(puntosController.text.trim()),
                        estado: estado,
                      );

                      Navigator.pop(dialogContext, insignia);
                    },
                    child: const Text('Crear insignia'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (resultado == null) return;

      String? rutaImagen;

      // 1. Subir imagen a Storage.

      if (imagenBytes != null) {
        final extension = archivoSeleccionado == null
            ? 'png'
            : archivoSeleccionado!.name
            .split('.')
            .last
            .toLowerCase();

        rutaImagen = await widget.badgeService.subirImagen(
          idMuseo: widget.idMuseo,
          bytes: imagenBytes!,
          extension: extension,
        );
      }


      // 2. Crear insignia con la ruta de la imagen.
      final nuevaInsignia = modelo.Badge(
        idInsignia: '',
        idMuseo: resultado.idMuseo,
        nombre: resultado.nombre,
        descripcion: resultado.descripcion,
        condicion: resultado.condicion,
        imagen: rutaImagen,
        puntosRequeridos: resultado.puntosRequeridos,
        estado: resultado.estado,
      );

      try {
        await widget.badgeService.crear(nuevaInsignia);
      } catch (e) {
        // Si falla el registro, intentamos eliminar el archivo subido.
        if (rutaImagen != null) {
          try {
            await widget.badgeService.eliminarImagen(rutaImagen);
          } catch (_) {
            // No ocultamos el error original.
          }
        }

        rethrow;
      }

      if (!mounted) return;

      await _cargarInsignias();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insignia creada correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear la insignia: $e'),
        ),
      );
    } finally {
      nombreController.dispose();
      descripcionController.dispose();
      condicionController.dispose();
      puntosController.dispose();
      generadorController.dispose();
    }
  }

  // ==========================================
  // CAMBIAR ESTADO
  // ==========================================

  Future<void> _cambiarEstado(modelo.Badge insignia) async {
    try {
      await widget.badgeService.cambiarEstado(
        insignia.idInsignia,
        !insignia.estado,
      );

      if (!mounted) return;

      _mostrarMensaje(
        insignia.estado
            ? 'Insignia desactivada.'
            : 'Insignia activada.',
      );

      await _cargarInsignias();

    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje('Error al cambiar el estado: $e');
    }
  }

  // ==========================================
  // ELIMINAR INSIGNIA
  // ==========================================

  Future<void> _eliminarInsignia(
      modelo.Badge insignia,
      ) async {

    final confirmar = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar insignia'),

          content: Text(
            '¿Estás seguro de que querés eliminar "${insignia.nombre}"?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8B3A3A),
              ),

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
      await widget.badgeService.eliminar(
        insignia.idInsignia,
      );

      if (!mounted) return;

      _mostrarMensaje('Insignia eliminada correctamente.');

      await _cargarInsignias();

    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje('Error al eliminar: $e');
    }
  }

  // ==========================================
  // CAMPO DE TEXTO REUTILIZABLE
  // ==========================================

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    bool obligatorio = false,
    int maxLines = 1,
    int? maxLength,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,

      decoration: _decoracionCampo(
        label,
        hint: hint,
      ),

      validator: obligatorio
          ? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }

        return null;
      }
          : null,
    );
  }

  InputDecoration _decoracionCampo(
      String label, {
        IconData? icono,
        String? hint,
      }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icono != null ? Icon(icono) : null,

      filled: true,
      fillColor: const Color(0xFFF9F6F0),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borde),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borde),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _acento, width: 1.5),
      ),
    );
  }

  // ==========================================
  // TARJETA DE INSIGNIA
  // ==========================================

  Widget _buildInsigniaCard(modelo.Badge insignia) {
    final imagenUrl =
    widget.badgeService.obtenerImagenUrl(insignia.imagen);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGEN
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: imagenUrl != null
                      ? Image.network(
                    imagenUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;

                      return Container(
                        color: _fondo,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF8B6F47),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _placeholderInsignia();
                    },
                  )
                      : _placeholderInsignia(),
                ),
              ),

              const SizedBox(width: 14),

              // INFORMACIÓN
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insignia.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _texto,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (insignia.descripcion != null &&
                        insignia.descripcion!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        insignia.descripcion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _texto.withValues(alpha: 0.7),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // PUNTOS
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFB38A42),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${insignia.puntosRequeridos} puntos',
                          style: TextStyle(
                            color: _acento,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // OPCIONES
              PopupMenuButton<String>(
                tooltip: 'Opciones',
                icon: Icon(
                  Icons.more_vert,
                  color: _texto.withValues(alpha: 0.7),
                ),
                onSelected: (opcion) {
                  if (opcion == 'editar') {
                    // Pendiente de implementar edición.
                  } else if (opcion == 'eliminar') {
                    _eliminarInsignia(insignia);
                  } else if (opcion == 'estado') {
                    _cambiarEstado(insignia);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('Modificar'),
                      ],
                    ),
                  ),

                  PopupMenuItem(
                    value: 'estado',
                    child: Row(
                      children: [
                        Icon(
                          insignia.estado
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          insignia.estado ? 'Desactivar' : 'Activar',
                        ),
                      ],
                    ),
                  ),

                  const PopupMenuItem(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // CONDICIÓN
          if (insignia.condicion != null &&
              insignia.condicion!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _fondo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Condición: ${insignia.condicion}',
                style: TextStyle(
                  fontSize: 12,
                  color: _texto.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // ESTADO
          Row(
            children: [
              Icon(
                insignia.estado
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: insignia.estado
                    ? Colors.green
                    : Colors.red,
                size: 17,
              ),
              const SizedBox(width: 6),
              Text(
                insignia.estado ? 'Activa' : 'Inactiva',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: insignia.estado
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PLACEHOLDER DE IMAGEN
  // ==========================================

  Widget _placeholderInsignia() {
    return Container(
      color: const Color(0xFFE8DFD2),
      alignment: Alignment.center,

      child: Icon(
        Icons.workspace_premium_outlined,
        size: 38,
        color: _acento,
      ),
    );
  }

  // ==========================================
  // LISTA DE INSIGNIAS
  // ==========================================

  Widget _buildInsignias() {
    if (_insignias.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),

          child: Column(
            children: [

              Icon(
                Icons.workspace_premium_outlined,
                size: 60,
                color: _acento,
              ),

              const SizedBox(height: 14),

              Text(
                'Todavía no hay insignias registradas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _texto,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Creá una insignia para comenzar a configurar las recompensas del museo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF756F68),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _insignias.map((insignia) {
        return _buildInsigniaCard(insignia);
      }).toList(),
    );
  }

  // ==========================================
  // BUILD PRINCIPAL
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,

      appBar: AppBar(
        title: const Text('Gestionar insignias'),
        backgroundColor: _fondo,
        foregroundColor: _texto,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),

        backgroundColor: _acento,
        foregroundColor: Colors.white,

        icon: const Icon(Icons.add),
        label: const Text('Nueva insignia'),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarInsignias,

          child: _cargando
              ? const Center(
            child: CircularProgressIndicator(),
          )

              : _error != null
              ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 100),

              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  'Error al cargar las insignias',
                  style: TextStyle(color: _texto),
                ),
              ),

              Center(
                child: TextButton(
                  onPressed: _cargarInsignias,
                  child: const Text('Reintentar'),
                ),
              ),
            ],
          )

              : ListView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(
              18, 18, 18, 90,
            ),

            children: [

              // ENCABEZADO
              Text(
                'Catálogo de insignias',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _texto,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Administrá las recompensas que los visitantes pueden desbloquear durante sus recorridos.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: _texto.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 20),

              // CONTADOR
              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: const Color(0xFFE8DFD2),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [

                    Icon(
                      Icons.workspace_premium,
                      color: _acento,
                      size: 28,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Total de insignias registradas',
                        style: TextStyle(
                          color: _texto,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    Text(
                      '${_insignias.length}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _acento,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // LISTADO
              _buildInsignias(),
            ],
          ),
        ),
      ),
    );
  }
}
