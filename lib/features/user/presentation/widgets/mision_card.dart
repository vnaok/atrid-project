// lib/widgets/visitante/mision_card.dart

import 'package:flutter/material.dart';

class MisionCard extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String? imagen;
  final String dificultad;
  final int? duracionEstimada;
  final int cantidadDesafios;
  final VoidCallback onVerMision;

  const MisionCard({
    super.key,
    required this.nombre,
    required this.descripcion,
    this.imagen,
    required this.dificultad,
    this.duracionEstimada,
    this.cantidadDesafios = 0,
    required this.onVerMision,
  });

  static const Color fondo = Color(0xFFF5EFE6);
  static const Color texto = Color(0xFF292621);
  static const Color borde = Color(0xFFD6CEC2);
  static const Color acento = Color(0xFF8A6748);

  Color _colorDificultad() {
    switch (dificultad.toLowerCase()) {
      case 'facil':
      case 'fácil':
        return Colors.green.shade700;
      case 'media':
        return Colors.orange.shade800;
      case 'dificil':
      case 'difícil':
        return Colors.red.shade700;
      default:
        return acento;
    }
  }

  Widget _imagenMision() {
    if (imagen == null || imagen!.isEmpty) {
      return Container(
        height: 160,
        color: const Color(0xFFE9E0D4),
        child: const Center(
          child: Icon(Icons.museum_outlined, size: 48, color: acento),
        ),
      );
    }

    return Image.network(
      imagen!,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 160,
        color: const Color(0xFFE9E0D4),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              size: 42, color: acento),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: fondo,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _imagenMision(),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: fondo.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    dificultad.toUpperCase(),
                    style: TextStyle(
                      color: _colorDificultad(),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    color: texto,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  descripcion,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: texto.withOpacity(0.8),
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (duracionEstimada != null)
                      _DatoMision(
                        icono: Icons.schedule_outlined,
                        texto: '$duracionEstimada min',
                      ),
                    _DatoMision(
                      icono: Icons.extension_outlined,
                      texto: '$cantidadDesafios desafíos',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onVerMision,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Ver misión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: texto,
                      foregroundColor: fondo,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatoMision extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _DatoMision({
    required this.icono,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 16, color: MisionCard.acento),
        const SizedBox(width: 5),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 12,
            color: MisionCard.texto,
          ),
        ),
      ],
    );
  }
}