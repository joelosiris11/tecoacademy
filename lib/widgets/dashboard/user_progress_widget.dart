import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProgressWidget extends StatelessWidget {
  const UserProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de usuarios de ejemplo
    final List<Map<String, dynamic>> users = [
      {'name': 'Ana García', 'xp': 2500},
      {'name': 'Carlos López', 'xp': 2300},
      {'name': 'María Rodríguez', 'xp': 2100},
      {'name': 'Juan Pérez', 'xp': 1900},
      {'name': 'Laura Torres', 'xp': 1800},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso de Usuarios',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        users[index]['name'],
                        style: GoogleFonts.roboto(fontSize: 16),
                      ),
                      Text(
                        '${users[index]['xp']} XP',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
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
