import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/AuthService.dart';
import '../../../core/supabase/supabase_client.dart';

import 'OnboardingEntryPage.dart';
import '../models/UserProfile.dart';

import '../../admin/presentation/AdminHomePage.dart';
//import 'VisitorHomePage.dart';
import '../../user/presentation/UserHomePage.dart';
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService(supabase);

  StreamSubscription<AuthState>? _authSubscription;

  bool _loading = true;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();

    _checkSession();

    _authSubscription =
        supabase.auth.onAuthStateChange.listen((authState) {
          debugPrint(
            'AUTH EVENT: ${authState.event}',
          );

          _checkSession();
        });
  }

  Future<void> _checkSession() async {
    try {
      debugPrint('========== AUTH GATE ==========');

      final session = supabase.auth.currentSession;

      debugPrint('SESSION: ${session != null}');

      if (session == null) {
        if (!mounted) return;

        setState(() {
          _profile = null;
          _loading = false;
        });

        return;
      }

      final profile = await _authService.getProfile();

      debugPrint('PROFILE: $profile');
      debugPrint('ROLE: ${profile?.rol}');

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e, stack) {
      debugPrint('ERROR AUTH GATE: $e');
      debugPrint('$stack');

      if (!mounted) return;

      setState(() {
        _profile = null;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'BUILD AUTH GATE → loading=$_loading profile=${_profile?.rol}',
    );

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (supabase.auth.currentSession == null) {
      return const OnboardingEntryPage();
    }

    if (_profile == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No se pudo cargar el perfil.',
          ),
        ),
      );
    }
    if (_profile!.rol == 'admin_museo') {
      debugPrint('>>> MOSTRANDO ADMIN HOME <<<');

      return const AdminHomePage();
    }

    if (_profile!.rol == 'visitante') {
      return const UserHomePage(museoId: 'd4b38809-ad57-45e6-95d1-fe8e328e82a2');
    }

    return Scaffold(
      body: Center(
        child: Text(
          'Rol desconocido: ${_profile!.rol}',
        ),
      ),
    );
  }
}


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