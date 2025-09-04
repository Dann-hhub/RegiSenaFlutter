import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({super.key, required this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showPasswordForm = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _getRolName(int? rolId) {
    switch (rolId) {
      case 1:
        return 'Administrador';
      case 2:
        return 'Supervisor';
      case 3:
        return 'Instructor';
      case 4:
        return 'Aprendiz';
      default:
        return 'Usuario';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

 Future<void> _cambiarContrasena() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final url = Uri.parse('http://127.0.0.1:5000/update-password');
        
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'documento': widget.userData['documento'],
            'contrasenaActual': _currentPasswordController.text,
            'nuevaContrasena': _newPasswordController.text,
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success']) {
          _mostrarMensajeExito('Contraseña cambiada exitosamente');
          _resetForm();
        } else {
          _mostrarError(data['message'] ?? 'Error al cambiar contraseña');
        }
      } catch (e) {
        _mostrarError('Error de conexión: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _resetForm() {
    setState(() => _showPasswordForm = false);
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.userData['nombre'] ?? 'Nombre no disponible';
    final apellido = widget.userData['apellido'] ?? 'Apellido no disponible';
    final documento = widget.userData['documento'] ?? 'Documento no disponible';
    final tipoDocumento = widget.userData['tipoDocumento'] ?? 'CC';
    final correo = widget.userData['correo'] ?? 'Correo no disponible';
    final rolId = widget.userData['rol'] is String 
        ? int.tryParse(widget.userData['rol']) 
        : widget.userData['rol'];

    final nombreCompleto = '$nombre $apellido'.trim();
    final documentoCompleto = '$tipoDocumento - $documento';
    final correocompleto = '$correo'.trim();
    final rol = _getRolName(rolId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF128941),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF128941).withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Color(0xFF128941),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mi Perfil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF128941),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      _buildProfileItem('Nombre Completo', nombreCompleto),
                      _buildProfileItem('Documento', documentoCompleto),
                      _buildProfileItem('Correo', correocompleto),
                      _buildProfileItem('Rol', rol),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (!_showPasswordForm)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showPasswordForm = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF128941),
                      ),
                      child: const Text(
                        'Cambiar Contraseña',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (_showPasswordForm) ...[
                  const SizedBox(height: 30),
                  const Divider(height: 40, thickness: 2),
                  const Text(
                    'Cambiar Contraseña',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF128941),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      children: [
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          label: 'Contraseña actual',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su contraseña actual';
                            }
                            return null;
                          },
                        ),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          label: 'Contraseña nueva',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese una nueva contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: 'Confirmar contraseña',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor confirme su nueva contraseña';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _cambiarContrasena ,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF128941),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'Cambiar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _showPasswordForm = false;
                                        });
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
            ),
            validator: validator,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}