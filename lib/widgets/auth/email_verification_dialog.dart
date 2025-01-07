import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'dart:developer' as developer;
import 'dart:async';

class EmailVerificationDialog extends StatefulWidget {
  final Function(String userId) onVerified;

  const EmailVerificationDialog({Key? key, required this.onVerified})
      : super(key: key);

  @override
  _EmailVerificationDialogState createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  final _emailController = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    final email = _emailController.text.trim();
    developer.log('Iniciando verificación para email: $email');

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa un email');
      return;
    }

    if (!email.contains('@')) {
      setState(() => _errorMessage = 'Por favor ingresa un email válido');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      developer.log('Buscando usuario con email: $email');

      // Intentamos obtener el usuario por email
      final usersQuery = await _firebaseService.users
          .where('profile.email', isEqualTo: email)
          .limit(1)
          .get();

      developer.log(
          'Resultado de la búsqueda: ${usersQuery.docs.length} documentos encontrados');

      if (usersQuery.docs.isEmpty) {
        setState(() {
          _errorMessage = 'No se encontró ningún usuario con este email';
          _isLoading = false;
        });
        return;
      }

      final userId = usersQuery.docs.first.id;
      developer.log('ID de usuario encontrado: $userId');

      // Primero cerramos el diálogo
      if (!mounted) return;
      Navigator.of(context).pop();

      // Luego llamamos al callback de verificación
      widget.onVerified(userId);
    } catch (e) {
      developer.log('Error durante la verificación: $e', error: e);
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al verificar el email: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Verificar Email',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                errorText: _errorMessage,
                prefixIcon: Icon(Icons.email),
                enabled: !_isLoading,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _verifyEmail(),
              autofocus: true,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Verificar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
