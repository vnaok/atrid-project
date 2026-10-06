import 'package:flutter/material.dart';
//import 'TurHomePage.dart';
import 'LoginPage.dart';
import 'RegisterPage.dart';

import '../../turista/presentation/TuristaHomePage.dart';

class OnboardingEntryPage extends StatelessWidget {
  const OnboardingEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: Stack(
        children: [
          // =========================
          // FONDO
          // =========================
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEADCCA),
                  Color(0xFFD2B48C),
                  Color(0xFFF5EFE6),
                ],
              ),
            ),
          ),

          // =========================
          // CONTENIDO
          // =========================
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // =========================
                  // CABECERA / LOGO
                  // =========================
                  SizedBox(
                    height: 420,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F6F0),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF8B6F47),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.museum_rounded,
                              color: Color(0xFF8B6F47),
                              size: 64,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Nombre
                          const Text(
                            'ATRID APP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF8B6F47),
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Línea
                          Container(
                            width: 60,
                            height: 2,
                            color: const Color(0xFF8B6F47),
                          ),

                          const SizedBox(height: 4),

                          // Subtítulo
                          const Text(
                            'Descubriendo Pico Truncado',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF756F68),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // =========================
                  // PANEL INFERIOR
                  // =========================
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9F6F0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          // =========================
                          // BIENVENIDA
                          // =========================
                          const Text(
                            'Bienvenido, visitante!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF292621),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Viaja al pasado y descubre los secretos '
                                'de antiguos pobladores a través de desafíos.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF756F68),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // =========================
                          // LOGIN
                          // =========================
                          _AuthOptionButton(
                            icon: Icons.login_rounded,
                            text: 'Iniciar sesion',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // =========================
                          // REGISTRO
                          // =========================
                          _AuthOptionButton(
                            icon: Icons.person_add_rounded,
                            text: 'Crea una nueva cuenta',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterPage(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // =========================
                          // DIVISOR
                          // =========================
                          const Divider(
                            height: 16,
                            indent: 24,
                            endIndent: 24,
                            color: Color(0xFFD6CEC2),
                          ),

                          const SizedBox(height: 16),

                          // =========================
// INVITADO
// =========================

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TuristaHomePage(

                                      museoId: 'd4b38809-ad57-45e6-95d1-fe8e328e82a2',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.hiking_rounded,
                                color: Color(0xFF292621),
                              ),
                              label: const Text(
                                'Explora como invitado',
                                style: TextStyle(
                                  color: Color(0xFF292621),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFD6CEC2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // =========================
                          // ADMIN
                          // =========================
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Eres un administrador?',
                                      style: TextStyle(
                                        color: Color(0xFF756F68),
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Acceso rapido',
                                      style: TextStyle(
                                        color: Color(0xFF8B6F47),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        decoration:
                                        TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      child: Divider(
                                        color: Color(0xFFD6CEC2),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                      child: Icon(
                                        Icons.local_florist_rounded,
                                        color: Color(0xFF756F68),
                                        size: 16,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 40,
                                      child: Divider(
                                        color: Color(0xFFD6CEC2),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// BOTÓN DE AUTENTICACIÓN
// ============================================================

class _AuthOptionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _AuthOptionButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF1EBE1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD6CEC2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF8B6F47),
                size: 24,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF292621),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF8B6F47),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}