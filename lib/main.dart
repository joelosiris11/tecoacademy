import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/dashboard.dart';
import 'pages/social_feed.dart';
import 'pages/osiris/osiris_page.dart';
import 'services/firebase_service.dart';
import 'widgets/auth/email_verification_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teco Academy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showEmailVerification(BuildContext context, bool isDashboard) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => EmailVerificationDialog(
        onVerified: (String userId) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => isDashboard
                  ? DashboardPage(initialUserId: userId)
                  : SocialFeed(userId: userId),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createTestUser(BuildContext context) async {
    final FirebaseService firebaseService = FirebaseService();
    final String userId =
        'cristian_bustamante_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // Crear el documento del usuario
      await firebaseService.users.doc(userId).set({
        'profile': {
          'email': 'cristian.bustamante@example.com',
          'username': 'cristian_bustamante',
          'fullName': 'Cristian Bustamante',
          'role': 'estudiante',
          'bio': 'Estudiante de programación',
          'xpTotal': 0,
          'level': 1
        },
        'schedule': {
          'days': ['Lunes', 'Miércoles', 'Viernes'],
          'shift': 'matutino'
        },
        'stats': {'postsCount': 0, 'completedCourses': 0}
      });

      // Crear estadísticas del usuario
      await firebaseService.statistics.doc(userId).set({
        'weeklyActivity': [4.2, 3.8, 6.5, 4.9, 5.2, 3.1, 2.8],
        'completedCourses': 0,
        'currentProgress': 0,
        'totalHours': 0,
        'platformUsage': {
          'Teco Platform': 0,
          'Zoom': 0,
          'Google Meet': 0,
        },
        'progress': {
          'total': 0,
          'inProgress': 0,
          'completed': 0,
          'upcoming': 0,
        },
        'currentCourse': {
          'title': 'Introducción a Flutter',
          'description': 'Aprende los fundamentos de Flutter',
          'progress': 0,
          'participants': [userId]
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Teco Academy'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showEmailVerification(context, false),
                  icon: const Icon(Icons.people),
                  label: const Text('Social Feed'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _showEmailVerification(context, true),
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Dashboard'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _createTestUser(context),
                  icon: const Icon(Icons.login),
                  label: const Text('Crear Usuario de Prueba'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.rocket_launch_outlined),
              color: Colors.grey.withOpacity(0.3),
              iconSize: 32,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OsirisPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
