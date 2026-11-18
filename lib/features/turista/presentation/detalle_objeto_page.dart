import 'package:flutter/material.dart';

import '../../../core/supabase/supabase_client.dart';
import '../model/ObjetoMuseo.dart';

class DetalleObjetoPage extends StatelessWidget {
  final ObjetoMuseo objeto;

  const DetalleObjetoPage({
    super.key,
    required this.objeto,
  });

  @override
  Widget build(BuildContext context) {
    final String? rutaImagen = objeto.imagen?.trim();

    final String? imagenUrl =
    rutaImagen != null && rutaImagen.isNotEmpty
        ? supabase.storage
        .from('objetos-museo')
        .getPublicUrl(rutaImagen)
        : null;

    final bool tieneImagen =
        imagenUrl != null &&
            imagenUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        foregroundColor: const Color(0xFF292621),
        elevation: 0,
        title: const Text(
          'Detalle del objeto',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IMAGEN GRANDE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),

              child: SizedBox(
                width: double.infinity,
                height: 260,

                child: tieneImagen
                    ? Image.network(
                  imagenUrl!,
                  fit: BoxFit.cover,

                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return _buildImagePlaceholder();
                  },
                )
                    : _buildImagePlaceholder(),
              ),
            ),

            const SizedBox(height: 24),

            // NOMBRE
            Text(
              objeto.nombre,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF292621),
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPCIÓN
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B6F47),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              objeto.descripcion,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF292621),
              ),
            ),

            // UBICACIÓN
            if (objeto.ubicacion != null &&
                objeto.ubicacion!.trim().isNotEmpty) ...[
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD6CEC2),
                  ),
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF8B6F47),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        objeto.ubicacion!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF292621),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


Widget _buildImagePlaceholder({
  bool cargando = false,
}) {
  return Container(
    width: 78,
    height: 78,
    color: const Color(0xFFE8DFD0),

    child: Center(
      child: cargando
          ? const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF8B6F47),
        ),
      )
          : const Icon(
        Icons.museum_rounded,
        color: Color(0xFF8B6F47),
        size: 32,
      ),
    ),
  );
}
