import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';

class MyScheduleWidget extends StatefulWidget {
  final String userId;

  MyScheduleWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _MyScheduleWidgetState createState() => _MyScheduleWidgetState();
}

class _MyScheduleWidgetState extends State<MyScheduleWidget> {
  final FirebaseService _firebaseService = FirebaseService();
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset - 300,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollRight() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset + 300,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showClassDescription(
      BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Descripción:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, String scheduleId, String className) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Clase'),
          content:
              Text('¿Estás seguro que deseas eliminar la clase "$className"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _firebaseService.deleteSchedule(scheduleId);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mi Horario',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left),
                      onPressed: _scrollLeft,
                    ),
                    Text('Today'),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      onPressed: _scrollRight,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firebaseService.users.doc(widget.userId).snapshots(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasError) {
                    return Center(child: Text('Error: ${userSnapshot.error}'));
                  }

                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final userData =
                      userSnapshot.data?.data() as Map<String, dynamic>?;
                  if (userData == null) {
                    return Center(child: Text('No se encontró el usuario'));
                  }

                  final schedule =
                      userData['schedule'] as Map<String, dynamic>?;
                  final userTeam = schedule?['team'] as String?;

                  if (userTeam == null) {
                    return Center(
                        child: Text('Usuario no asignado a un equipo'));
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: _firebaseService.schedules
                        .where('schedule.team', isEqualTo: userTeam)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final schedules = snapshot.data?.docs ?? [];
                      if (schedules.isEmpty) {
                        return Center(
                            child: Text(
                                'No hay clases programadas para tu equipo'));
                      }

                      return Stack(
                        children: [
                          SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: schedules.map((doc) {
                                final schedule =
                                    doc.data() as Map<String, dynamic>;
                                final teacher = schedule['teacher']
                                    as Map<String, dynamic>?;
                                final scheduleData = schedule['schedule']
                                    as Map<String, dynamic>?;
                                final team = scheduleData?['team'] as String? ??
                                    'Sin días asignados';
                                final description =
                                    schedule['description'] as String? ??
                                        'Sin descripción disponible';
                                final isEvenClass =
                                    schedules.indexOf(doc) % 2 == 0;
                                final cardColor = isEvenClass
                                    ? Color(0xFF1a237e)
                                    : Color(0xFF1b5e20);

                                return Container(
                                  width: 280,
                                  margin: EdgeInsets.only(right: 16),
                                  child: Card(
                                    elevation: 4,
                                    color: cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${scheduleData?['startTime'] ?? '9:00'} - ${scheduleData?['endTime'] ?? '0:00'}',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              InkWell(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: true,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          schedule['name'] ??
                                                              'Sin nombre',
                                                          style: TextStyle(
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        content:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Descripción:',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                          .grey[
                                                                      700],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 8),
                                                              Text(
                                                                description,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                          .grey[
                                                                      800],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                            child: Text(
                                                              'Cerrar',
                                                            ),
                                                          ),
                                                        ],
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                  schedule['name'] ??
                                                      'Sin nombre',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationStyle:
                                                        TextDecorationStyle
                                                            .dotted,
                                                    decorationColor:
                                                        Colors.white70,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                team,
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Divider(color: Colors.white24),
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.white24,
                                                    child: Text(
                                                      ((teacher?['name']
                                                                  as String?) ??
                                                              'P')[0]
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      (teacher?['name']
                                                              as String?) ??
                                                          'Sin profesor asignado',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white70,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.white70,
                                            ),
                                            onPressed: () =>
                                                _showDeleteConfirmation(
                                              context,
                                              doc.id,
                                              schedule['name'] ?? 'Sin nombre',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: IconButton(
                                icon: Icon(Icons.chevron_left, size: 30),
                                onPressed: _scrollLeft,
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.white.withOpacity(0.8)),
                                  shape:
                                      MaterialStateProperty.all(CircleBorder()),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: IconButton(
                                icon: Icon(Icons.chevron_right, size: 30),
                                onPressed: _scrollRight,
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.white.withOpacity(0.8)),
                                  shape:
                                      MaterialStateProperty.all(CircleBorder()),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
