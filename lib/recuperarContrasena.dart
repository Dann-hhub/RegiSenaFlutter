import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recuperación de Contraseña',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PasswordRecoveryPage(),
    );
  }
}

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _newPassword;

  String _generateRandomPassword() {
    const length = 10;
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    )
    );
  }

  Future<void> _updatePasswordInDatabase(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': email,
          'nuevaContrasena': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar la contraseña en la base de datos');
      }
    } catch (e) {
      throw Exception('Error de conexión con el servidor');
    }
  }

  Future<void> _sendRecoveryEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _newPassword = _generateRandomPassword();
    });

    try {
      // 1. Primero actualizar la contraseña en la base de datos
      await _updatePasswordInDatabase(_emailController.text, _newPassword!);

      // 2. Enviar el correo con la nueva contraseña
      final username = 'danielespinosasierra198@gmail.com';
      final password = 'ewlq yesh etbg orrp';

      final smtpServer = gmail(username, password);
      
      final message = Message()
        ..from = Address(username, 'Soporte SENA')
        ..recipients.add(_emailController.text)
        ..subject = 'Recuperación de contraseña - SENA'
        ..text = 'Tu nueva contraseña es: $_newPassword\n\n'
                'Por favor cambia esta contraseña después de iniciar sesión.';

      await send(message, smtpServer);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo enviado con éxito. Revisa tu bandeja de entrada.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    } on MailerException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar correo: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña', style: TextStyle(color: Colors.white)),
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
              children: [
                const Text(
                  'Recuperación de Contraseña',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ingresa tu correo electrónico para recibir una nueva contraseña',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su correo electrónico';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Ingrese un correo electrónico válido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendRecoveryEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF128941),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Enviar nueva contraseña',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}