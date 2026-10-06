/*import 'package:flutter/material.dart';

class TuristaHomePage extends StatelessWidget {
  const TuristaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Color(0xFF292621),
        ),

        title: const Text(
          'Exploradores del Museo',
          style: TextStyle(
            color: Color(0xFF292621),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Icono
                Container(
                  width: 110,
                  height: 110,

                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F6F0),
                    shape: BoxShape.circle,

                    border: Border.all(
                      color: const Color(0xFF8B6F47),
                      width: 2,
                    ),
                  ),

                  child: const Icon(
                    Icons.hiking_rounded,
                    color: Color(0xFF8B6F47),
                    size: 56,
                  ),
                ),

                const SizedBox(height: 28),

                // Título
                const Text(
                  'Entraste como invitado',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Color(0xFF292621),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Descripción
                const Text(
                  'Podés explorar el museo como visitante '
                      'sin crear una cuenta.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Color(0xFF756F68),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Aviso
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EBE1),
                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(
                      color: const Color(0xFFD6CEC2),
                    ),
                  ),

                  child: const Column(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF8B6F47),
                        size: 28,
                      ),

                      SizedBox(height: 10),

                      Text(
                        'Modo invitado',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Color(0xFF292621),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        'El progreso de tus exploraciones no '
                            'se guardará mientras estés como invitado.',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Color(0xFF756F68),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Botón volver
                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: const Icon(
                      Icons.arrow_back_rounded,
                    ),

                    label: const Text(
                      'Volver',
                    ),

                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                      const Color(0xFF8B6F47),

                      side: const BorderSide(
                        color: Color(0xFF8B6F47),
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
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
}*/