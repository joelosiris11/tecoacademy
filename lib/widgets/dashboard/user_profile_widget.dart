import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import '../../pages/social_feed.dart';

class UserProfileWidget extends StatelessWidget {
  final String userId;

  UserProfileWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        if (userData == null) {
          return Text('No se encontró el usuario');
        }

        final profile = userData['profile'] as Map<String, dynamic>?;
        final username = profile?['username'] as String? ?? 'Usuario';
        final role = profile?['role'] as String? ?? 'Estudiante';
        final level = profile?['level'] as int? ?? 1;

        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SocialFeed(userId: userId),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        username[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$role · Nivel $level',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
