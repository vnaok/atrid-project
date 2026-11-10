// lib/widgets/visitante/objeto_card.dart

import 'package:flutter/material.dart';

class ObjetoCard extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String? imagen;
  final String? ubicacion;
  final VoidCallback? onTap;

  const ObjetoCard({
    super.key,
    required this.nombre,
    required this.descripcion,
    this.imagen,
    this.ubicacion,
    this.onTap,
  });

  static const Color fondo = Color(0xFFF5EFE6);
  static const Color texto = Color(0xFF292621);
  static const Color borde = Color(0xFFD6CEC2);
  static const Color acento = Color(0xFF8A6748);

  Widget _construirImagen() {
    if (imagen == null || imagen!.isEmpty) {
      return Container(
        color: const Color(0xFFE9E0D4),
        child: const Center(
          child: Icon(
            Icons.account_balance_outlined,
            size: 42,
            color: acento,
          ),
        ),
      );
    }

    return Image.network(
      imagen!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: const Color(0xFFE9E0D4),
          child: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 38,
              color: acento,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: fondo,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: _construirImagen(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: texto,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: texto.withOpacity(0.8),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  if (ubicacion != null && ubicacion!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: acento,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ubicacion!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: acento,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}