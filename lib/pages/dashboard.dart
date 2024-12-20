import 'package:flutter/material.dart';
import '../widgets/dashboard/user_profile_widget.dart';
import '../widgets/dashboard/user_progress_widget.dart';
import '../widgets/dashboard/my_schedule_widget.dart';
import '../widgets/dashboard/my_team_widget.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Columna izquierda (40% del ancho)
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: const [
                        // Perfil de usuario (40% del alto)
                        Expanded(
                          flex: 4,
                          child: UserProfileWidget(),
                        ),
                        SizedBox(height: 16),
                        // Progreso de usuarios (60% del alto)
                        Expanded(
                          flex: 6,
                          child: UserProgressWidget(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Columna derecha (60% del ancho)
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        // Cronograma (40% del alto)
                        const Expanded(
                          flex: 4,
                          child: MyScheduleWidget(),
                        ),
                        const SizedBox(height: 16),
                        // Equipo y configuración (60% del alto)
                        Expanded(
                          flex: 6,
                          child: Stack(
                            children: [
                              const MyTeamWidget(),
                              Positioned(
                                right: 16,
                                bottom: 16,
                                child: FloatingActionButton(
                                  onPressed: () {
                                    // Implementar acción de configuración
                                  },
                                  child: const Icon(Icons.settings),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
