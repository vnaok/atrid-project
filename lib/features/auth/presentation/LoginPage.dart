import 'package:flutter/material.dart';
import '../../admin/presentation/AdminHomePage.dart';
import '../../user/presentation/UserHomePage.dart';
import '../services/AuthService.dart';
import '../../../core/supabase/supabase_client.dart';
import 'RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService(supabase);

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    try {
      debugPrint('========== LOGIN ==========');
      debugPrint('1. Intentando iniciar sesión');

      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      debugPrint('2. Login ejecutado');

      final user = _authService.currentUser;

      debugPrint('3. Usuario: ${user?.id}');
      debugPrint(
        '4. Session: ${_authService.currentSession != null}',
      );

      if (!mounted) return;

      debugPrint('5. Cerrando LoginPage');
      Navigator.of(context).pop();

    } catch (e) {
      debugPrint('ERROR LOGIN: $e');

      if (!mounted) return;

      // Acá después podemos mostrar el error al usuario.
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // =========================================================
              // ENCABEZADO
              // =========================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                child: Column(
                  children: [

                    // Botón volver
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF756F68),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Icono museo
                    Container(
                      width: 90,
                      height: 90,
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
                        size: 48,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'ATRID APP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8B6F47),
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: 50,
                      height: 2,
                      color: const Color(0xFF8B6F47),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Descubrí, explorá y preservá nuestro patrimonio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF756F68),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // =========================================================
              // FORMULARIO
              // =========================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),

                decoration: const BoxDecoration(
                  color: Color(0xFFF9F6F0),

                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),

                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      const Text(
                        'Nos alegra tenerte de nuevo!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF292621),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Ingresá para continuar tu exploración.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF756F68),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =================================================
                      // EMAIL
                      // =================================================

                      const Text(
                        'Email',
                        style: TextStyle(
                          color: Color(0xFF292621),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _emailController,

                        keyboardType: TextInputType.emailAddress,

                        textInputAction: TextInputAction.next,

                        style: const TextStyle(
                          color: Color(0xFF292621),
                        ),

                        decoration: InputDecoration(
                          hintText: 'Ingresá tu email',

                          hintStyle: const TextStyle(
                            color: Color(0xFF756F68),
                          ),

                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF8B6F47),
                          ),

                          filled: true,

                          fillColor: const Color(0xFFF1EBE1),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFD6CEC2),
                            ),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFD6CEC2),
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF8B6F47),
                              width: 2,
                            ),
                          ),

                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                            ),
                          ),

                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
                          ),
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Ingresá tu email';
                          }

                          if (!value.contains('@')) {
                            return 'Ingresá un email válido';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // =================================================
                      // CONTRASEÑA
                      // =================================================

                      const Text(
                        'Contraseña',
                        style: TextStyle(
                          color: Color(0xFF292621),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _passwordController,

                        obscureText: _obscurePassword,

                        textInputAction: TextInputAction.done,

                        style: const TextStyle(
                          color: Color(0xFF292621),
                        ),

                        decoration: InputDecoration(
                          hintText: 'Ingresá tu contraseña',

                          hintStyle: const TextStyle(
                            color: Color(0xFF756F68),
                          ),

                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFF8B6F47),
                          ),

                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,

                              color: const Color(0xFF756F68),
                            ),

                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                !_obscurePassword;
                              });
                            },
                          ),

                          filled: true,

                          fillColor: const Color(0xFFF1EBE1),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFD6CEC2),
                            ),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFD6CEC2),
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF8B6F47),
                              width: 2,
                            ),
                          ),

                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                            ),
                          ),

                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
                          ),
                        ),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresá tu contraseña';
                          }

                          return null;
                        },

                        onFieldSubmitted: (_) {
                          if (!_loading) {
                            _iniciarSesion();
                          }
                        },
                      ),

                      const SizedBox(height: 28),

                      // =================================================
                      // BOTÓN INGRESAR
                      // =================================================

                      SizedBox(
                        height: 56,

                        child: ElevatedButton.icon(
                          onPressed:
                          _loading ? null : _iniciarSesion,

                          icon: _loading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(
                            Icons.login_rounded,
                          ),

                          label: Text(
                            _loading
                                ? 'Ingresando...'
                                : 'Iniciar sesión',
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF8B6F47),

                            foregroundColor:
                            const Color(0xFFF9F6F0),

                            disabledBackgroundColor:
                            const Color(0xFFD2B48C),

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),

                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // =================================================
                      // DIVISOR
                      // =================================================

                      const Row(
                        children: [
                          Expanded(
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

                          Expanded(
                            child: Divider(
                              color: Color(0xFFD6CEC2),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // =================================================
                      // REGISTRO
                      // =================================================

                      const Text(
                        '¿Todavía no tenés una cuenta?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF756F68),
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const RegisterPage(),
                            ),
                          );
                        },

                        child: const Text(
                          'Crear una cuenta',
                          style: TextStyle(
                            color: Color(0xFF8B6F47),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration:
                            TextDecoration.underline,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Volver al inicio
                      TextButton.icon(
                        onPressed: _loading
                            ? null
                            : () {
                          Navigator.pop(context);
                        },

                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 16,
                        ),

                        label: const Text(
                          'Volver',
                        ),

                        style: TextButton.styleFrom(
                          foregroundColor:
                          const Color(0xFF756F68),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}