import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyScheduleWidget extends StatelessWidget {
  const MyScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> schedule = [
      {
        'day': 'Lunes',
        'class': 'Matemáticas Avanzadas',
        'time': '09:00 - 10:30'
      },
      {
        'day': 'Martes',
        'class': 'Programación Flutter',
        'time': '11:00 - 12:30'
      },
      {'day': 'Miércoles', 'class': 'Desarrollo Web', 'time': '14:00 - 15:30'},
      {'day': 'Jueves', 'class': 'Base de Datos', 'time': '10:00 - 11:30'},
      {'day': 'Viernes', 'class': 'Proyecto Final', 'time': '15:00 - 16:30'},
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
            'Mi Horario',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: schedule.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(
                      schedule[index]['class']!,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${schedule[index]['day']} | ${schedule[index]['time']}',
                      style: GoogleFonts.roboto(),
                    ),
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.blue),
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
