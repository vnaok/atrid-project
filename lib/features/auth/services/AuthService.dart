import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/UserProfile.dart';

class AuthService {
  final SupabaseClient supabase;

  AuthService(this.supabase);

  // =========================
  // REGISTRO
  // =========================

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String nombre,
    String? apellido,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'nombre': nombre,
        'apellido': apellido,
      },
    );
  }

  // =========================
  // LOGIN
  // =========================

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // =========================
  // USUARIO ACTUAL
  // =========================

  User? get currentUser {
    return supabase.auth.currentUser;
  }

  // =========================
  // SESIÓN ACTUAL
  // =========================

  Session? get currentSession {
    return supabase.auth.currentSession;
  }

  // =========================
  // PERFIL DEL USUARIO
  // =========================

  Future<UserProfile?> getProfile() async {
    final user = currentUser;

    print('========== GET PROFILE ==========');
    print('USER: ${user?.id}');
    print('SESSION: ${currentSession != null}');

    if (user == null) {
      print('NO HAY USUARIO');
      return null;
    }

    try {
      final data = await supabase
          .from('perfiles')
          .select('id_usuario, nombre, apellido, rol')
          .eq('id_usuario', user.id);

      print('RESULTADO PERFILES: $data');
      print('CANTIDAD: ${data.length}');

      if (data.isEmpty) {
        return null;
      }

      return UserProfile.fromMap(data.first);
    } catch (e, stack) {
      print('ERROR PERFIL: $e');
      print(stack);
      rethrow;
    }
  }



  // =========================
  // ROL DEL USUARIO
  // =========================

  Future<String?> getUserRole() async {
    final profile = await getProfile();

    return profile?.rol;
  }

  // =========================
  // SESIÓN INICIADA
  // =========================

  bool get isLoggedIn {
    return currentSession != null;
  }
}