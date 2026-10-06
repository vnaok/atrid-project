import 'package:flutter/material.dart';

import '../../missions/presentation/GestionarMisionesPage.dart';
import '../../objects//presentation/GestionarObjetosPage.dart';
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF292621),
            ),
            onPressed: () {
              // Configuración futura
            },
          ),
        ],
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

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: const [

                  _MetricCard(
                    icon: Icons.people_outline,
                    title: 'Visitantes',
                    value: '142',
                  ),

                  _MetricCard(
                    icon: Icons.flag_outlined,
                    title: 'Misiones',
                    value: '12',
                  ),

                  _MetricCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Objetos',
                    value: '35',
                  ),

                  _MetricCard(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Insignias',
                    value: '8',
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                        children: const [
                          _ChartBar(day: 'L', value: 45),
                          _ChartBar(day: 'M', value: 62),
                          _ChartBar(day: 'X', value: 85),
                          _ChartBar(day: 'J', value: 55),
                          _ChartBar(day: 'V', value: 92),
                          _ChartBar(day: 'S', value: 70),
                          _ChartBar(day: 'D', value: 110),
                        ],
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
                      // TODO:
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
                      // TODO:
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // =====================================================
              // ACTIVIDAD RECIENTE
              // =====================================================

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

              const SizedBox(height: 32),

              // =====================================================
              // CERRAR SESIÓN
              // =====================================================

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Luego conectamos AuthService.logout()
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
  final double value;

  const _ChartBar({
    required this.day,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 22,
              height: value,
              decoration: BoxDecoration(
                color: const Color(0xFF8B6F47),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: const TextStyle(
            fontSize: 11,
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