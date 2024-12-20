import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTeamWidget extends StatelessWidget {
  const MyTeamWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> teamMembers = [
      {'name': 'Roberto Sánchez', 'role': 'Líder de Equipo'},
      {'name': 'Patricia Flores', 'role': 'Desarrollador'},
      {'name': 'Miguel Ángel', 'role': 'Diseñador UI/UX'},
      {'name': 'Isabel Moreno', 'role': 'Desarrollador'},
      {'name': 'David Torres', 'role': 'Tester'},
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
            'Mi Equipo',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Equipo: Innovadores Tech',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: teamMembers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Text(
                      teamMembers[index]['name']![0],
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  title: Text(
                    teamMembers[index]['name']!,
                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    teamMembers[index]['role']!,
                    style: GoogleFonts.roboto(),
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
