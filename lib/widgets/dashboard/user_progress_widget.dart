import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';

class UserProgressWidget extends StatefulWidget {
  @override
  _UserProgressWidgetState createState() => _UserProgressWidgetState();
}

class _UserProgressWidgetState extends State<UserProgressWidget> {
  final FirebaseService _firebaseService = FirebaseService();
  final List<Color> _avatarColors = [
    Color(0xFF1976D2), // Azul intenso
    Color(0xFF2E7D32), // Verde intenso
    Color(0xFFF57C00), // Naranja intenso
    Color(0xFFFBC02D), // Amarillo intenso
  ];

  Color _getAvatarColor(int index) {
    if (_avatarColors.isEmpty) {
      return Colors.blue; // Color por defecto si la lista está vacía
    }
    // Asegurarse de que el índice sea positivo antes de usar el operador módulo
    final safeIndex = index.abs() % _avatarColors.length;
    return _avatarColors[safeIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progreso de Usuarios',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 300, // Altura fija para el contenedor
              child: StreamBuilder<QuerySnapshot>(
                stream: _firebaseService.users.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data?.docs ?? [];
                  if (users.isEmpty) {
                    return Text('No hay usuarios registrados');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(), // Permitir scroll
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userData =
                          users[index].data() as Map<String, dynamic>;
                      final profile =
                          userData['profile'] as Map<String, dynamic>? ?? {};
                      final username =
                          (profile['username'] as String?)?.trim() ?? 'Usuario';
                      final role = profile['role'] as String? ?? 'Estudiante';
                      final xp = profile['xpTotal'] as int? ?? 0;
                      final level = profile['level'] as int? ?? 1;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _getAvatarColor(index),
                              child: Text(
                                (username.isNotEmpty ? username[0] : 'U')
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    role,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'XP',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[300],
                                  ),
                                ),
                                Text(
                                  '$xp',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[300],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 16),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Nivel $level',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
