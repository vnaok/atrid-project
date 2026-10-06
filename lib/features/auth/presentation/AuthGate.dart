import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/AuthService.dart';
import '../../../core/supabase/supabase_client.dart';

import 'OnboardingEntryPage.dart';
import '../models/UserProfile.dart';

import '../../admin/presentation/AdminHomePage.dart';
import 'VisitorHomePage.dart';

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

    if (_profile!.rol == 'usuario') {
      return const VisitorHomePage();
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