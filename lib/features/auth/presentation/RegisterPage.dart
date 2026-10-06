import 'package:flutter/material.dart';

import '../services/AuthService.dart';
import '../../../core/supabase/supabase_client.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService(supabase);

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _registrarse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registro exitoso. Revisá tu correo para confirmar la cuenta.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrarse: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // =========================================================
  // ESTILO COMÚN PARA LOS CAMPOS
  // =========================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(
        color: Color(0xFF756F68),
      ),

      prefixIcon: Icon(
        icon,
        color: const Color(0xFF8B6F47),
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
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // =======================================================
              // ENCABEZADO
              // =======================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  32,
                  24,
                  32,
                  28,
                ),
                child: Column(
                  children: [

                    // Volver
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _loading
                            ? null
                            : () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF756F68),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Icono
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F6F0),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF8B6F47),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: Color(0xFF8B6F47),
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'EXPLORADORES DEL MUSEO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8B6F47),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Container(
                      width: 50,
                      height: 2,
                      color: const Color(0xFF8B6F47),
                    ),

                    const SizedBox(height: 9),

                    const Text(
                      'Comenzá tu aventura',
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

              // =======================================================
              // FORMULARIO
              // =======================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.fromLTRB(
                  28,
                  30,
                  28,
                  32,
                ),

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
                        'Crear una cuenta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF292621),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Registrate para guardar tu progreso '
                            'y participar de las experiencias.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF756F68),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // =================================================
                      // NOMBRE
                      // =================================================

                      const Text(
                        'Nombre',
                        style: TextStyle(
                          color: Color(0xFF292621),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 7),

                      TextFormField(
                        controller: _nombreController,

                        textInputAction: TextInputAction.next,

                        style: const TextStyle(
                          color: Color(0xFF292621),
                        ),

                        decoration: _inputDecoration(
                          hintText: 'Ingresá tu nombre',
                          icon: Icons.person_outline_rounded,
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Ingresá tu nombre';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 17),

                      // =================================================
                      // APELLIDO
                      // =================================================

                      const Text(
                        'Apellido',
                        style: TextStyle(
                          color: Color(0xFF292621),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 7),

                      TextFormField(
                        controller: _apellidoController,

                        textInputAction: TextInputAction.next,

                        style: const TextStyle(
                          color: Color(0xFF292621),
                        ),

                        decoration: _inputDecoration(
                          hintText: 'Ingresá tu apellido',
                          icon: Icons.person_outline_rounded,
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Ingresá tu apellido';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 17),

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

                      const SizedBox(height: 7),

                      TextFormField(
                        controller: _emailController,

                        keyboardType:
                        TextInputType.emailAddress,

                        textInputAction:
                        TextInputAction.next,

                        style: const TextStyle(
                          color: Color(0xFF292621),
                        ),

                        decoration: _inputDecoration(
                          hintText: 'Ingresá tu email',
                          icon: Icons.email_outlined,
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

                      const SizedBox(height: 17),

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

                      const SizedBox(height: 7),

                      TextFormField(
                        controller: _passwordController,

                        obscureText: _obscurePassword,

                        textInputAction: TextInputAction.done,

                        style: const TextStyle(
                          color: Color(0xFF292621),
                        ),

                        decoration: _inputDecoration(
                          hintText: 'Ingresá una contraseña',
                          icon: Icons.lock_outline_rounded,
                        ).copyWith(
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
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Ingresá una contraseña';
                          }

                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }

                          return null;
                        },

                        onFieldSubmitted: (_) {
                          if (!_loading) {
                            _registrarse();
                          }
                        },
                      ),

                      const SizedBox(height: 26),

                      // =================================================
                      // BOTÓN REGISTRARSE
                      // =================================================

                      SizedBox(
                        height: 56,

                        child: ElevatedButton.icon(
                          onPressed:
                          _loading ? null : _registrarse,

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
                            Icons.person_add_rounded,
                          ),

                          label: Text(
                            _loading
                                ? 'Creando cuenta...'
                                : 'Crear cuenta',
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
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

                      const SizedBox(height: 22),

                      // =================================================
                      // LOGIN
                      // =================================================

                      const Text(
                        '¿Ya tenés una cuenta?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF756F68),
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 7),

                      TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                          Navigator.pop(context);
                        },

                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Color(0xFF8B6F47),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration:
                            TextDecoration.underline,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Volver
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