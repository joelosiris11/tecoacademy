import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';

class TecoManagerWidget extends StatefulWidget {
  @override
  _TecoManagerWidgetState createState() => _TecoManagerWidgetState();
}

class _TecoManagerWidgetState extends State<TecoManagerWidget> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  // Controladores para usuario
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  // Controladores para clase
  final _classNameController = TextEditingController();
  final _classDescriptionController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _teacherNameController = TextEditingController();

  // Controladores para equipos (uno por equipo)
  final Map<String, TextEditingController> _teamControllers = {};

  bool _showOptions = false;
  bool _isLoading = false;
  String _selectedOption = '';
  String _selectedRole = 'estudiante';
  String _selectedShift = 'matutino';
  String? _selectedTeam;
  final List<String> _selectedDays = [];

  final List<String> _teams = [
    'Lunes y Jueves',
    'Martes y Viernes',
    'Miércoles y Sábado'
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar un controlador para cada equipo
    for (final team in _teams) {
      _teamControllers[team] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose controladores de usuario
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();

    // Dispose controladores de clase
    _classNameController.dispose();
    _classDescriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _teacherNameController.dispose();

    // Dispose controladores de equipos
    for (final controller in _teamControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _resetForm() {
    // Reset campos de usuario
    _fullNameController.clear();
    _usernameController.clear();
    _emailController.clear();
    _bioController.clear();

    // Reset campos de clase
    _classNameController.clear();
    _classDescriptionController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _teacherNameController.clear();

    setState(() {
      _selectedRole = 'estudiante';
      _selectedShift = 'matutino';
      _selectedDays.clear();
      _selectedTeam = null;
      _selectedOption = '';
      _showOptions = false;
      _isLoading = false;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_selectedOption == 'usuario') {
        await _createUser();
      } else if (_selectedOption == 'clase') {
        await _createClass();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedOption} creado exitosamente')),
      );

      _resetForm();
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear ${_selectedOption}: $e')),
      );
    }
  }

  Future<void> _createUser() async {
    final String userId = DateTime.now().millisecondsSinceEpoch.toString();

    final userData = {
      'profile': {
        'email': _emailController.text,
        'username': _usernameController.text.toLowerCase().replaceAll(' ', '_'),
        'fullName': _fullNameController.text,
        'role': _selectedRole,
        'bio': _bioController.text,
        'xpTotal': 0,
        'level': 1
      },
      'schedule': {'days': _selectedDays, 'shift': _selectedShift},
      'stats': {'postsCount': 0, 'completedCourses': 0}
    };

    final statsData = {
      'weeklyActivity': List.filled(7, 0),
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
    };

    final batch = FirebaseFirestore.instance.batch();
    batch.set(_firebaseService.users.doc(userId), userData);
    batch.set(_firebaseService.statistics.doc(userId), statsData);
    await batch.commit();
  }

  Future<void> _createClass() async {
    try {
      // Buscar el profesor por nombre
      final teacherQuery = await _firebaseService.users
          .where('profile.role', isEqualTo: 'teacher')
          .get();

      // Buscamos el profesor manualmente para hacer una comparación más flexible
      final teacherDoc = teacherQuery.docs.firstWhere(
        (doc) {
          final data = doc.data() as Map<String, dynamic>;
          final profile = data['profile'] as Map<String, dynamic>?;
          if (profile == null) return false;

          final teacherName =
              profile['fullName']?.toString().toLowerCase() ?? '';
          final searchName = _teacherNameController.text.toLowerCase();

          // Normalizamos los nombres para la comparación (removemos acentos)
          final normalizedTeacherName = teacherName
              .replaceAll('á', 'a')
              .replaceAll('é', 'e')
              .replaceAll('í', 'i')
              .replaceAll('ó', 'o')
              .replaceAll('ú', 'u');
          final normalizedSearchName = searchName
              .replaceAll('á', 'a')
              .replaceAll('é', 'e')
              .replaceAll('í', 'i')
              .replaceAll('ó', 'o')
              .replaceAll('ú', 'u');

          return normalizedTeacherName == normalizedSearchName;
        },
        orElse: () =>
            throw Exception('No se encontró un profesor con ese nombre'),
      );

      // Buscar estudiantes del equipo seleccionado
      final studentsQuery = await _firebaseService.users
          .where('schedule.team', isEqualTo: _selectedTeam)
          .where('profile.role', isEqualTo: 'estudiante')
          .get();

      final studentIds = studentsQuery.docs.map((doc) => doc.id).toList();

      final String classId = 'class_${DateTime.now().millisecondsSinceEpoch}';
      final teacherId = teacherDoc.id;
      final data = teacherDoc.data() as Map<String, dynamic>;
      final teacherData = data['profile'] as Map<String, dynamic>;

      final classData = {
        'name': _classNameController.text,
        'description': _classDescriptionController.text,
        'schedule': {
          'team': _selectedTeam,
          'days': _selectedTeam?.split(' y ') ?? [],
          'startTime': _startTimeController.text,
          'endTime': _endTimeController.text,
        },
        'teacher': {
          'id': teacherId,
          'name': teacherData['fullName'],
        },
        'students': studentIds, // Agregamos los IDs de los estudiantes
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firebaseService.schedules.doc(classId).set(classData);

      print('Clase creada con ID: $classId');
      print('Estudiantes agregados: $studentIds');
    } catch (e) {
      print('Error al crear la clase: $e');
      throw e;
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTimeController.text =
              '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
        } else {
          _endTimeController.text =
              '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
        }
      });
    }
  }

  Future<void> _addUserToTeam(String team, String userName) async {
    setState(() => _isLoading = true);

    try {
      // Buscar el usuario por nombre
      final userQuery = await _firebaseService.users
          .where('profile.fullName', isEqualTo: userName)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('No se encontró el usuario');
      }

      final userId = userQuery.docs.first.id;
      final userData = userQuery.docs.first.data() as Map<String, dynamic>;

      // Actualizar el horario del usuario
      await _firebaseService.users.doc(userId).update({
        'schedule': {
          'team': team,
          'days': team.split(' y '),
          'shift': userData['schedule']?['shift'] ?? 'matutino',
        }
      });

      // Limpiar solo el controlador del equipo específico
      setState(() {
        _teamControllers[team]?.clear();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario agregado al equipo exitosamente')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildClassForm() {
    return ListView(
      shrinkWrap: true,
      children: [
        TextFormField(
          controller: _classNameController,
          decoration: InputDecoration(
            labelText: 'Nombre de la Clase',
            border: OutlineInputBorder(),
          ),
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa el nombre de la clase';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _classDescriptionController,
          decoration: InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(),
          ),
          enabled: !_isLoading,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa una descripción';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _teacherNameController,
          decoration: InputDecoration(
            labelText: 'Nombre del Profesor',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
            hintText: 'Ingresa el nombre completo del profesor',
          ),
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa el nombre del profesor';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedTeam,
          decoration: InputDecoration(
            labelText: 'Equipo',
            border: OutlineInputBorder(),
          ),
          items: _teams.map((String team) {
            return DropdownMenuItem(
              value: team,
              child: Text(team),
            );
          }).toList(),
          onChanged: _isLoading
              ? null
              : (String? value) {
                  setState(() {
                    _selectedTeam = value;
                  });
                },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor selecciona un equipo';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _startTimeController,
                decoration: InputDecoration(
                  labelText: 'Hora de Inicio',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: _isLoading ? null : () => _selectTime(true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _endTimeController,
                decoration: InputDecoration(
                  labelText: 'Hora de Fin',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: _isLoading ? null : () => _selectTime(false),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserForm() {
    return ListView(
      shrinkWrap: true,
      children: [
        TextFormField(
          controller: _fullNameController,
          decoration: InputDecoration(
            labelText: 'Nombre Completo',
            border: OutlineInputBorder(),
          ),
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa el nombre completo';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Nombre de Usuario',
            border: OutlineInputBorder(),
          ),
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un nombre de usuario';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un email';
            }
            if (!value.contains('@')) {
              return 'Por favor ingresa un email válido';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          decoration: InputDecoration(
            labelText: 'Biografía',
            border: OutlineInputBorder(),
          ),
          enabled: !_isLoading,
          maxLines: 3,
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: InputDecoration(
            labelText: 'Rol',
            border: OutlineInputBorder(),
          ),
          items: ['estudiante', 'profesor', 'admin'].map((String role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role.toUpperCase()),
            );
          }).toList(),
          onChanged: _isLoading
              ? null
              : (String? value) {
                  setState(() {
                    _selectedRole = value ?? 'estudiante';
                  });
                },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedShift,
          decoration: InputDecoration(
            labelText: 'Turno',
            border: OutlineInputBorder(),
          ),
          items: ['matutino', 'vespertino', 'nocturno'].map((String shift) {
            return DropdownMenuItem(
              value: shift,
              child: Text(shift.toUpperCase()),
            );
          }).toList(),
          onChanged: _isLoading
              ? null
              : (String? value) {
                  setState(() {
                    _selectedShift = value ?? 'matutino';
                  });
                },
        ),
        SizedBox(height: 16),
        Text('Días de clase:', style: TextStyle(fontSize: 16)),
        Wrap(
          spacing: 8,
          children: [
            'Lunes',
            'Martes',
            'Miércoles',
            'Jueves',
            'Viernes',
            'Sábado'
          ].map((String day) {
            return FilterChip(
              label: Text(day),
              selected: _selectedDays.contains(day),
              onSelected: _isLoading
                  ? null
                  : (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTeamManagement() {
    return Column(
      children: [
        Text(
          'Gestión de Equipos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: _teams.map((team) {
            return Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firebaseService.users
                            .where('schedule.team', isEqualTo: team)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error al cargar usuarios');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          final users = snapshot.data?.docs ?? [];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...users.map((user) {
                                final userData =
                                    user.data() as Map<String, dynamic>;
                                final profile =
                                    userData['profile'] as Map<String, dynamic>;
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.blue[100],
                                        child: Text(
                                          profile['fullName']
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          profile['fullName'],
                                          style: TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _teamControllers[
                                          team], // Usar el controlador específico del equipo
                                      decoration: InputDecoration(
                                        hintText: 'Nombre del usuario',
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.add_circle),
                                    color: Colors.blue,
                                    onPressed: _isLoading
                                        ? null
                                        : () => _addUserToTeam(team,
                                            _teamControllers[team]?.text ?? ''),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teco Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() {
                              _selectedOption = 'usuario';
                              _formKey.currentState?.reset();
                            }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOption == 'usuario'
                          ? Colors.blue
                          : Colors.grey[300],
                      foregroundColor: _selectedOption == 'usuario'
                          ? Colors.white
                          : Colors.black,
                    ),
                    child: Text('Usuario'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() {
                              _selectedOption = 'clase';
                              _formKey.currentState?.reset();
                            }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOption == 'clase'
                          ? Colors.blue
                          : Colors.grey[300],
                      foregroundColor: _selectedOption == 'clase'
                          ? Colors.white
                          : Colors.black,
                    ),
                    child: Text('Clase'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() {
                              _selectedOption = 'equipos';
                              _formKey.currentState?.reset();
                            }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOption == 'equipos'
                          ? Colors.blue
                          : Colors.grey[300],
                      foregroundColor: _selectedOption == 'equipos'
                          ? Colors.white
                          : Colors.black,
                    ),
                    child: Text('Equipos'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_selectedOption.isNotEmpty)
              _selectedOption == 'equipos'
                  ? _buildTeamManagement()
                  : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _selectedOption == 'usuario'
                              ? _buildUserForm()
                              : _buildClassForm(),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _selectedOption = '';
                                          });
                                          _resetForm();
                                        },
                                  child: Text('Cancelar'),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSubmit,
                                  child: _isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text('Guardar'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}
