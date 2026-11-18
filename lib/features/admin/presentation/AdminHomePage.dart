import 'package:flutter/material.dart';
import 'package:prueba_flutter/features/badges/presentation/GestionarInsigniasPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



import '../../../core/supabase/supabase_client.dart';
import '../../auth/services/AuthService.dart';
import '../../badges/services/badgeService.dart';
import '../../challenges/presentation/gestionar_desafios_page.dart';

import '../../missions/presentation/GestionarMisionesPage.dart';
import '../../objects//presentation/GestionarObjetosPage.dart';
import '../services/analytics_service.dart';


class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {

  static const String _museoId =
      'd4b38809-ad57-45e6-95d1-fe8e328e82a2';

  late final AnalyticsService _analyticsService;

  int _totalMisiones = 0;
  int _totalInsignias = 0;
  int _totalObjetos = 0;
  int _totalCuentas = 0;

  List<Map<String, dynamic>> _iniciosUltimos7Dias = [];

  bool _cargandoGrafico = true;

  bool _cargandoMetricas = true;
  String? _errorMetricas;

  @override
  void initState() {
    super.initState();

    _analyticsService = AnalyticsService(
      Supabase.instance.client,
    );

    _cargarMetricas();
  }


  String _obtenerDiaSemana(int dia) {
    const dias = [
      'L', 'M', 'X', 'J', 'V', 'S', 'D'
    ];

    return dias[dia - 1];
  }

  Future<void> _cargarMetricas() async {
    try {
      setState(() {

        _cargandoMetricas = true;
        _errorMetricas = null;

      });



      final resultados = await Future.wait<int>([
        _analyticsService.contarMisionesTotales(_museoId),
        _analyticsService.contarInsignias(_museoId),
        _analyticsService.contarObjetos(_museoId),
        _analyticsService.contarCuentasCreadas(),

      ]);

      final inicios = await _analyticsService
          .obtenerIniciosUltimos7Dias('d4b38809-ad57-45e6-95d1-fe8e328e82a2');

      if (!mounted) return;

      setState(() {
        _totalMisiones = resultados[0];
        _totalInsignias = resultados[1];
        _totalObjetos = resultados[2];
        _totalCuentas = resultados[3];
        _iniciosUltimos7Dias = inicios;
      });

    } catch (e) {
      debugPrint('Error al cargar métricas: $e');

      if (!mounted) return;

      setState(() {
        _errorMetricas = 'No se pudieron cargar las métricas.';
      });

    } finally {
      if (mounted) {
        setState(() {
          _cargandoMetricas = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final int maxInicios = _iniciosUltimos7Dias.isEmpty
        ? 0
        : _iniciosUltimos7Dias
        .map((dia) => dia['cantidad'] as int)
        .reduce((a, b) => a > b ? a : b);


    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exploradores del Museo',
              style: TextStyle(
                color: Color(0xFF292621),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Panel de administración',
              style: TextStyle(
                color: Color(0xFF756F68),
                fontSize: 13,
              ),
            ),
          ],
        ),
        /*actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF292621),
            ),
            onPressed: () {
              // Configuración futura
            },
          ),
        ],*/
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =====================================================
              // BIENVENIDA
              // =====================================================

              const Text(
                'Panel de control',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF292621),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Gestioná el contenido y consultá la actividad del museo.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF756F68),
                ),
              ),

              const SizedBox(height: 24),

              // =====================================================
              // MÉTRICAS
              // =====================================================



              const Text(
                'Resumen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF292621),
                ),
              ),

              const SizedBox(height: 12),

              if (_errorMetricas != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFF8B3A3A),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMetricas!,
                          style: const TextStyle(
                            color: Color(0xFF8B3A3A),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _cargarMetricas,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Reintentar',
                      ),
                    ],
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _cargandoMetricas
                        ? null
                        : _cargarMetricas,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Actualizar métricas'),
                  ),
                ),

              const SizedBox(height: 8),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _MetricCard(
                    icon: Icons.people_outline,
                    title: 'Cuentas creadas',
                    value: _cargandoMetricas
                        ? '...'
                        : _totalCuentas.toString(),
                  ),

                  _MetricCard(
                    icon: Icons.flag_outlined,
                    title: 'Misiones',
                    value: _cargandoMetricas
                        ? '...'
                        : _totalMisiones.toString(),
                  ),

                  _MetricCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Objetos',
                    value: _cargandoMetricas
                        ? '...'
                        : _totalObjetos.toString(),
                  ),

                  _MetricCard(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Insignias',
                    value: _cargandoMetricas
                        ? '...'
                        : _totalInsignias.toString(),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // =====================================================
              // MÉTRICAS DE USO
              // =====================================================

              const Text(
                'Uso de la aplicación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF292621),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD6CEC2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Visitas esta semana',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.bar_chart_rounded,
                          color: Color(0xFF8B6F47),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 160,
                      child: _cargandoMetricas
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B6F47),
                        ),
                      )
                          : _iniciosUltimos7Dias.isEmpty
                          ? const Center(
                        child: Text(
                          'No hay visitas registradas esta semana.',
                          style: TextStyle(
                            color: Color(0xFF8B6F47),
                            fontSize: 13,
                          ),
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _iniciosUltimos7Dias.map((dia) {
                          final fecha = DateTime.parse(dia['fecha']);

                          return _ChartBar(
                            day: _obtenerDiaSemana(fecha.weekday),
                            value: dia['cantidad'] as int,
                            maxValue: maxInicios,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // =====================================================
              // GESTIÓN
              // =====================================================

              const Text(
                'Gestión del museo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF292621),
                ),
              ),

              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [

                  _ManagementCard(
                    icon: Icons.flag_outlined,
                    title: 'Misiones',
                    subtitle: 'Crear y editar misiones',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GestionarMisionesPage(
                            museoId: 'd4b38809-ad57-45e6-95d1-fe8e328e82a2',
                          ),
                        ),
                      );
                    },
                  ),
                  _ManagementCard(
                    icon: Icons.quiz_outlined,
                    title: 'Desafíos',
                    subtitle: 'Gestionar desafíos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GestionarDesafiosPage(
                            supabase: Supabase.instance.client,
                          ),
                        ),
                      );
                    },
                  ),

                  _ManagementCard(
                    icon: Icons.museum_outlined,
                    title: 'Objetos',
                    subtitle: 'Crear y editar objetos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GestionarObjetosPage(
                            museoId: 'd4b38809-ad57-45e6-95d1-fe8e328e82a2',
                          ),
                        ),
                      );
                    },
                  ),

                  _ManagementCard(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Insignias',
                    subtitle: 'Gestionar recompensas',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GestionarInsigniaPage(
                            idMuseo: 'd4b38809-ad57-45e6-95d1-fe8e328e82a2',
                            badgeService: BadgeService(supabase),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // =====================================================
              // ACTIVIDAD RECIENTE
              // =====================================================
/*
              const Text(
                'Actividad reciente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF292621),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD6CEC2),
                  ),
                ),
                child: const Column(
                  children: [

                    _ActivityItem(
                      icon: Icons.flag_outlined,
                      text: 'Un visitante completó una misión',
                      time: 'Hace 2 min',
                    ),

                    Divider(height: 1),

                    _ActivityItem(
                      icon: Icons.museum_outlined,
                      text: 'Un visitante descubrió un objeto',
                      time: 'Hace 5 min',
                    ),

                    Divider(height: 1),

                    _ActivityItem(
                      icon: Icons.play_arrow_outlined,
                      text: 'Un visitante inició una misión',
                      time: 'Hace 12 min',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),*/

              // =====================================================
              // CERRAR SESIÓN
              // =====================================================

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final authService = AuthService(
                        Supabase.instance.client,
                      );

                      await authService.logout();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sesión cerrada correctamente'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al cerrar sesión: $e'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B3A3A),
                    side: const BorderSide(
                      color: Color(0xFFD6CEC2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD6CEC2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF8B6F47),
            size: 25,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF292621),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF756F68),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD6CEC2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 34,
              color: const Color(0xFF8B6F47),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF292621),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF756F68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final String day;
  final int value;
  final int maxValue;

  const _ChartBar({
    required this.day,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final double altura = maxValue == 0
        ? 0
        : (value / maxValue) * 100;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF756F68),
          ),
        ),

        const SizedBox(height: 5),

        Container(
          width: 22,
          height: altura.clamp(4.0, 100.0),
          decoration: BoxDecoration(
            color: const Color(0xFF8B6F47),
            borderRadius: BorderRadius.circular(6),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          day,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF756F68),
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFE6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.circle,
              size: 10,
              color: Color(0xFF8B6F47),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF292621),
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF756F68),
            ),
          ),
        ],
      ),
    );
  }
}