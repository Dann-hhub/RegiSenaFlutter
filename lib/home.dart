import 'package:flutter/material.dart';
import 'main.dart';
import 'miPerfil.dart';
import 'equipos/home.dart';
import 'personas/home.dart';
import 'movimientos/home.dart';
import 'dashboard/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SENA App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile', arguments: userData);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 180,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF128941),
                ),
                child: Center(
                  child: ListTile(
                    leading: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Mi Perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/profile',
                        arguments: userData,
                      );
                    },
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.auto_graph, color: Color(0xFF128941)),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.perm_identity,
                color: Color(0xFF128941),
              ),
              title: const Text('Personas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PersonaListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.laptop, color: Color(0xFF128941)),
              title: const Text('Equipos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EquipmentListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.navigate_before,
                color: Color(0xFF128941),
              ),
              title: const Text('Movimientos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MovimientoListScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡Ingresaste a RegiSena!',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF128941),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Sistema de gestión para el registro de ingreso y salida de equipos electrónicos en el SENA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}