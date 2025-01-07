import 'package:flutter/material.dart';
import '../widgets/dashboard/user_profile_widget.dart';
import '../widgets/dashboard/user_progress_widget.dart';
import '../widgets/dashboard/my_schedule_widget.dart';
import '../widgets/dashboard/my_team_widget.dart';
import '../widgets/dashboard/teco_manager_widget.dart';

class DashboardPage extends StatelessWidget {
  final String? initialUserId;

  const DashboardPage({Key? key, this.initialUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna izquierda (40% del ancho)
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Perfil de usuario
                    Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: UserProfileWidget(
                          userId: initialUserId ?? 'student1'),
                    ),
                    const SizedBox(height: 16),
                    // Progreso de usuarios
                    Expanded(
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cronograma
                    Container(
                      constraints: BoxConstraints(maxHeight: 300),
                      child:
                          MyScheduleWidget(userId: initialUserId ?? 'student1'),
                    ),
                    const SizedBox(height: 16),
                    // Equipo y configuración
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            constraints: BoxConstraints(minHeight: 200),
                            child: MyTeamWidget(
                                userId: initialUserId ?? 'student1'),
                          ),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TecoManagerWidget(),
                                  ),
                                );
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
      ),
    );
  }
}
