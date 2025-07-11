import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerificationScreen extends StatefulWidget {
  final String email;
  final Map<String, dynamic> userData;

  const VerificationScreen({
    Key? key,
    required this.email,
    required this.userData,
  }) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _verificationCodeController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void dispose() {
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
  if (_verificationCodeController.text.length != 6) {
    setState(() {
      _errorMessage = 'El código debe tener 6 dígitos';
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
  });

  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'code': _verificationCodeController.text,
      }),
    );

    // Verificar si la respuesta está vacía
    if (response.body.isEmpty) {
      throw Exception('La respuesta del servidor está vacía');
    }

    final responseData = jsonDecode(response.body);

    // Verificar si responseData es nulo o no contiene los campos esperados
    if (responseData == null) {
      throw Exception('Datos de respuesta inválidos');
    }

    if (response.statusCode == 200 && responseData['success'] == true) {
      // Verificar que los datos del usuario existen
      if (responseData['user'] == null) {
        throw Exception('Datos de usuario no recibidos');
      }

      setState(() {
        _successMessage = 'Verificación exitosa';
      });
      
      // Navegar al home con los datos del usuario
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
        arguments: responseData['user'] as Map<String, dynamic>,
      );
    } else {
      setState(() {
        _errorMessage = responseData['message'] ?? 'Error en la verificación';
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Error: ${e.toString()}';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

Future<void> _resendCode() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
  });

  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/resend-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      setState(() {
        _successMessage = 'Nuevo código generado: ${responseData['code']}';
      });
    } else {
      setState(() {
        _errorMessage = responseData['message'] ?? 'Error al reenviar el código';
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Error de conexión: $e';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verificación'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.verified_user,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Validar Ingreso',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Ingrese el código de verificación',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              if (_successMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _successMessage,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              TextFormField(
                controller: _verificationCodeController,
                decoration: const InputDecoration(
                  labelText: 'Código de 6 dígitos',
                  prefixIcon: Icon(Icons.confirmation_number),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el código';
                  }
                  if (value.length != 6) {
                    return 'El código debe tener 6 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF128941),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Validar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              
              TextButton(
                onPressed: _isLoading ? null : _resendCode,
                child: const Text(
                  'Reenviar código',
                  style: TextStyle(color: Color(0xFF128941)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}