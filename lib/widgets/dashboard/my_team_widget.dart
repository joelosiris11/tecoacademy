import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';

class MyTeamWidget extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  final String userId;

  MyTeamWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firebaseService.users.doc(userId).snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasError) {
                  return Center(child: Text('Error al cargar el equipo'));
                }

                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Center(child: Text('Usuario no encontrado'));
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final schedule = userData['schedule'] as Map<String, dynamic>?;
                final team = schedule?['team'] as String?;

                if (team == null) {
                  return Center(
                      child: Text('No estás asignado a ningún equipo'));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: _firebaseService.users
                      .where('schedule.team', isEqualTo: team)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error al cargar los miembros'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final members = snapshot.data?.docs ?? [];

                    if (members.isEmpty) {
                      return Center(
                          child: Text('No hay miembros en el equipo'));
                    }

                    return ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final memberData =
                            members[index].data() as Map<String, dynamic>;
                        final profile =
                            memberData['profile'] as Map<String, dynamic>;
                        final name = profile['fullName'] ?? '';
                        final role = profile['role'] ?? '';
                        final isTeacher = role.toLowerCase() == 'profesor';

                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              role,
                              style: TextStyle(fontFamily: 'Roboto'),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: isTeacher
                                  ? Colors.blue[100]
                                  : Colors.grey[200],
                              child: Text(
                                name.isNotEmpty
                                    ? name.substring(0, 1).toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: isTeacher
                                      ? Colors.blue[900]
                                      : Colors.grey[800],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
