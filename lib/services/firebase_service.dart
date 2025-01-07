import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Colecciones principales
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get schedules => _firestore.collection('schedules');
  CollectionReference get courses => _firestore.collection('courses');
  CollectionReference get projects => _firestore.collection('projects');
  CollectionReference get social => _firestore.collection('social');
  CollectionReference get achievements => _firestore.collection('achievements');
  CollectionReference get statistics => _firestore.collection('statistics');
  // Acceso directo a posts como subcolección de social
  CollectionReference get posts =>
      _firestore.collection('social').doc('posts').collection('items');

  // Métodos para Usuarios
  Future<DocumentSnapshot> getUserProfile(String userId) async {
    return await users.doc(userId).get();
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await users.doc(userId).update(data);
  }

  // Métodos para Horarios
  Future<DocumentSnapshot> getGroupSchedule(String groupId) async {
    return await schedules.doc(groupId).get();
  }

  // Métodos para Cursos
  Future<DocumentSnapshot> getCourseDetails(String courseId) async {
    return await courses.doc(courseId).get();
  }

  Future<QuerySnapshot> getCourseModules(String courseId) async {
    return await courses.doc(courseId).collection('modules').get();
  }

  // Métodos para Proyectos
  Future<DocumentSnapshot> getProjectDetails(String projectId) async {
    return await projects.doc(projectId).get();
  }

  Future<void> updateProjectTask(
      String projectId, String taskId, Map<String, dynamic> data) async {
    await projects.doc(projectId).update({
      'kanban.tasks.$taskId': data,
    });
  }

  // Métodos para Social
  Future<QuerySnapshot> getGroupPosts(String groupId) async {
    return await posts
        .where('group', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<void> createPost(String postId, Map<String, dynamic> postData) async {
    await posts.doc(postId).set(postData);
  }

  // Métodos para Logros
  Future<QuerySnapshot> getUserAchievements(String userId) async {
    return await achievements.where('userId', isEqualTo: userId).get();
  }

  // Métodos para Estadísticas
  Future<DocumentSnapshot> getUserStatistics(String userId) async {
    return await statistics.doc(userId).get();
  }

  Future<void> updateUserStatistics(
      String userId, Map<String, dynamic> data) async {
    await statistics.doc(userId).update(data);
  }

  // Métodos de consulta compuesta
  Future<Map<String, dynamic>> getUserCompleteProfile(String userId) async {
    final userProfile = await getUserProfile(userId);
    final userStats = await getUserStatistics(userId);

    return {
      'profile': userProfile.data(),
      'statistics': userStats.data(),
    };
  }

  Future<List<DocumentSnapshot>> getGroupMembers(String groupId) async {
    final schedule = await getGroupSchedule(groupId);
    final scheduleData = schedule.data() as Map<String, dynamic>;

    final List<String> memberIds = [
      ...List<String>.from(scheduleData['students'] ?? []),
      scheduleData['teacher'],
    ];

    final futures = memberIds.map((id) => getUserProfile(id));
    return await Future.wait(futures);
  }

  Future<void> initializeStatisticsData() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // Documento de estadísticas para el dashboard
    await db.collection('statistics').doc('dashboard').set({
      'weeklyActivity': [4.2, 3.8, 6.5, 4.9, 5.2, 3.1, 2.8], // Horas por día
      'platformUsage': {
        'Teco Platform': 12.5,
        'Zoom': 6.8,
        'Google Meet': 4.2,
        'Discord': 2.5,
      },
      'progress': {
        'total': 64, // Porcentaje total
        'inProgress': 8,
        'completed': 12,
        'upcoming': 14,
      },
      'currentCourse': {
        'title': 'Flutter Development Advanced',
        'description':
            'Learn advanced Flutter patterns and Firebase integration',
        'progress': 75,
        'participants': ['user1', 'user2', 'user3', 'user4']
      },
      'schedule': [
        {
          'time': '09:30-11:00',
          'course': 'Technical Flutter',
          'level': 'Beginner',
          'mentor': {'name': 'Alex Rivera', 'photoUrl': 'assets/mentor1.jpg'}
        },
        {
          'time': '11:00-13:00',
          'course': 'Flutter Architecture',
          'level': 'Advanced',
          'mentor': {'name': 'Maria García', 'photoUrl': 'assets/mentor2.jpg'}
        },
        {
          'time': '15:00-17:00',
          'course': 'Firebase & Flutter',
          'level': 'Intermediate',
          'mentor': {'name': 'Carlos López', 'photoUrl': 'assets/mentor3.jpg'}
        }
      ]
    });
  }

  Future<Map<String, dynamic>> getFullUserData(String userId) async {
    try {
      // Obtener el documento completo del usuario
      final userDoc = await users.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      // Obtener estadísticas
      final statsDoc = await statistics.doc(userId).get();
      final statsData = statsDoc.data() as Map<String, dynamic>?;

      // Obtener logros
      final achievementsQuery =
          await achievements.where('userId', isEqualTo: userId).get();

      // Obtener proyectos
      final projectsQuery =
          await projects.where('members.$userId', isNull: false).get();

      return {
        'profile': userData['profile'] ?? {},
        'stats': userData['stats'] ?? {},
        'statistics': statsData ?? {},
        'achievements':
            achievementsQuery.docs.map((doc) => doc.data()).toList(),
        'projects': projectsQuery.docs.map((doc) => doc.data()).toList(),
      };
    } catch (e) {
      print('Error getting full user data: $e');
      rethrow;
    }
  }

  Future<void> initializeUserData() async {
    // Crear un documento de usuario de prueba
    await users.doc('test_user').set({
      'profile': {
        'email': 'test@example.com',
        'username': 'testuser',
        'fullName': 'Usuario de Prueba',
        'role': 'estudiante',
        'bio': 'Estudiante de Flutter',
        'avatarUrl': 'https://via.placeholder.com/60',
        'xpTotal': 1500,
        'level': 5
      },
      'schedule': {
        'days': ['Lunes', 'Miércoles', 'Viernes'],
        'shift': 'Mañana'
      },
      'stats': {'postsCount': 10, 'completedCourses': 3}
    });

    // Crear estadísticas del usuario
    await statistics.doc('test_user').set({
      'weeklyActivity': [4.2, 3.8, 6.5, 4.9, 5.2, 3.1, 2.8],
      'completedCourses': 3,
      'currentProgress': 75,
      'totalHours': 120,
      'platformUsage': {
        'Teco Platform': 12.5,
        'Zoom': 6.8,
        'Google Meet': 4.2,
      },
      'progress': {
        'total': 64,
        'inProgress': 8,
        'completed': 12,
        'upcoming': 14,
      },
      'currentCourse': {
        'title': 'Flutter Development Advanced',
        'description':
            'Learn advanced Flutter patterns and Firebase integration',
        'progress': 75,
        'participants': ['user1', 'user2', 'user3', 'user4']
      },
      'schedule': [
        {
          'time': '09:30-11:00',
          'course': 'Technical Flutter',
          'level': 'Beginner',
          'mentor': {'name': 'Alex Rivera', 'photoUrl': 'assets/mentor1.jpg'}
        },
        {
          'time': '11:00-13:00',
          'course': 'Flutter Architecture',
          'level': 'Advanced',
          'mentor': {'name': 'Maria García', 'photoUrl': 'assets/mentor2.jpg'}
        }
      ]
    });
  }

  // Obtener stream de horarios
  Stream<QuerySnapshot> getScheduleStream() {
    return _firestore.collection('schedules').snapshots();
  }
}
