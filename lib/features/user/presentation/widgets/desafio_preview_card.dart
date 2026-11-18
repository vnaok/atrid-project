// lib/widgets/visitante/desafio_preview_card.dart

import 'package:flutter/material.dart';

class DesafioPreviewCard extends StatelessWidget {
  final int orden;
  final String titulo;
  final String descripcion;
  final String tipo;
  final int puntos;

  const DesafioPreviewCard({
    super.key,
    required this.orden,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.puntos,
  });

  static const Color fondo = Color(0xFFF5EFE6);
  static const Color texto = Color(0xFF292621);
  static const Color borde = Color(0xFFD6CEC2);
  static const Color acento = Color(0xFF8A6748);

  IconData _iconoTipo() {
    switch (tipo.toLowerCase()) {
      case 'pregunta':
        return Icons.quiz_outlined;
      case 'busqueda_objeto':
      case 'busqueda objeto':
        return Icons.search_outlined;
      case 'escaneo_qr':
      case 'escaneo qr':
        return Icons.qr_code_scanner;
      case 'identificacion':
      case 'identificación':
        return Icons.image_search_outlined;
      default:
        return Icons.extension_outlined;
    }
  }

  String _nombreTipo() {
    switch (tipo.toLowerCase()) {
      case 'busqueda_objeto':
      case 'busqueda objeto':
        return 'Búsqueda de objeto';
      case 'escaneo_qr':
      case 'escaneo qr':
        return 'Escaneo QR';
      case 'identificacion':
      case 'identificación':
        return 'Identificación';
      case 'pregunta':
        return 'Pregunta';
      default:
        return tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fondo,
        border: Border.all(color: borde),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE9E0D4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$orden',
              style: const TextStyle(
                color: texto,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: texto,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  descripcion,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: texto.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _EtiquetaDesafio(
                      icono: _iconoTipo(),
                      texto: _nombreTipo(),
                    ),
                    _EtiquetaDesafio(
                      icono: Icons.stars_outlined,
                      texto: '$puntos puntos',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EtiquetaDesafio extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _EtiquetaDesafio({
    required this.icono,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 1),
        Icon(icono, size: 14, color: DesafioPreviewCard.acento),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(
            color: DesafioPreviewCard.texto,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}