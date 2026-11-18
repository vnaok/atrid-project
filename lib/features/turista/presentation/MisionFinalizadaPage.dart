import 'package:flutter/material.dart';

class MisionFinalizadaPage extends StatelessWidget {
  final int puntajeObtenido;
  final int desafiosCompletados;
  final int totalDesafios;
  final int respuestasCorrectas;

  final ValueChanged<int> onMisionFinalizada;
  final VoidCallback onVolverInicio;

  const MisionFinalizadaPage({
    super.key,
    required this.puntajeObtenido,
    required this.desafiosCompletados,
    required this.totalDesafios,
    required this.respuestasCorrectas,
    required this.onMisionFinalizada,

    required this.onVolverInicio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¡MISIÓN FINALIZADA!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF292621),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'Puntaje obtenido: $puntajeObtenido',
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 12),

              Text(
                'Desafíos completados: $desafiosCompletados',
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 12),

              Text(
                'Total de desafíos: $totalDesafios',
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 12),

              Text(
                'Respuestas correctas: $respuestasCorrectas',
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('========== FINALIZAR MISIÓN ==========');
                    debugPrint('Puntaje obtenido: $puntajeObtenido');

                    onMisionFinalizada.call(puntajeObtenido);

                    onVolverInicio();
                  },
                  child: const Text('Volver al inicio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


