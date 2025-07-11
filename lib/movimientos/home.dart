import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';

class Movimiento {
  final int id;
  final String documentoPersona;
  final String serialEquipo;
  final String centroFormacion;
  final String tipoIngreso;
  final String tipoSalida;
  final String fechaIngreso;
  final String fechaSalida;

  Movimiento({
    required this.id,
    required this.documentoPersona,
    required this.serialEquipo,
    required this.centroFormacion,
    required this.tipoIngreso,
    required this.tipoSalida,
    required this.fechaIngreso,
    required this.fechaSalida,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'] ?? 0,
      documentoPersona: json['documentoPersona'] ?? '',
      serialEquipo: json['serialEquipo'] ?? '',
      centroFormacion: json['centroFormacion'] ?? '',
      tipoIngreso: json['tipoIngreso'] ?? '',
      tipoSalida: json['tipoSalida'] ?? '',
      fechaIngreso: json['fechaIngreso'] ?? '',
      fechaSalida: json['fechaSalida'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentoPersona': documentoPersona,
      'serialEquipo': serialEquipo,
      'centroFormacion': centroFormacion,
      'tipoIngreso': tipoIngreso,
      'tipoSalida': tipoSalida,
      'fechaIngreso': fechaIngreso,
      'fechaSalida': fechaSalida,
    };
  }
}

class MovimientoListScreen extends StatefulWidget {
  const MovimientoListScreen({super.key});

  @override
  State<MovimientoListScreen> createState() => _MovimientoListScreenState();
}

class _MovimientoListScreenState extends State<MovimientoListScreen> {
  late Future<List<Movimiento>> futureMovimientos;
  final String apiUrl = 'http://127.0.0.1:5000/movimiento';
  List<Movimiento> movimientosList = [];
  List<Movimiento> filteredMovimientos = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureMovimientos = _fetchMovimientos();
    searchController.addListener(_filterMovimientos);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<Movimiento>> _fetchMovimientos() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        movimientosList =
            (data['movimientos'] as List)
                .map((e) => Movimiento.fromJson(e))
                .toList();
        filteredMovimientos = List.from(movimientosList);
        return movimientosList;
      } else {
        throw Exception('Error al cargar movimientos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar movimientos: $e');
    }
  }

  void _filterMovimientos() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredMovimientos =
          movimientosList.where((movimiento) {
            return movimiento.documentoPersona.toLowerCase().contains(query) ||
                movimiento.serialEquipo.toLowerCase().contains(query) ||
                movimiento.centroFormacion.toLowerCase().contains(query);
          }).toList();
    });
  }

  Future<void> _deleteMovimiento(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _refreshMovimientos();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movimiento eliminado correctamente')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar movimiento: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _refreshMovimientos() {
    setState(() {
      futureMovimientos = _fetchMovimientos();
    });
  }

  // Método para escanear QR
  Future<void> _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null) {
      // Procesar el resultado del escaneo
      final qrData = result as String;
      final parts = qrData.split('\n');

      if (parts.length >= 2) {
        final documentoPersona =
            parts[0].replaceFirst('Documento: ', '').trim();
        final serialEquipo = parts[1].replaceFirst('Equipo: ', '').trim();

        // Navegar a la pantalla de creación con los datos del QR
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AddEditMovimientoScreen(
                  isEditing: false,
                  initialData: {
                    'documentoPersona': documentoPersona,
                    'serialEquipo': serialEquipo,
                    'centroFormacion': 'CESGE',
                    'tipoIngreso': 'Permanente',
                    'fechaIngreso': DateTime.now().toString(),
                  },
                ),
          ),
        ).then((_) => _refreshMovimientos());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formato de QR no válido')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMovimientos,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar movimientos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movimiento>>(
              future: futureMovimientos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || filteredMovimientos.isEmpty) {
                  return const Center(
                    child: Text('No hay movimientos registrados'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: filteredMovimientos.length,
                    itemBuilder: (context, index) {
                      final movimiento = filteredMovimientos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.compare_arrows,
                            color: Colors.indigo,
                          ),
                          title: Text(
                            'Persona: ${movimiento.documentoPersona}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Equipo: ${movimiento.serialEquipo}'),
                              Text('Centro: ${movimiento.centroFormacion}'),
                              Text('Fecha Ingreso: ${movimiento.fechaIngreso}'),
                              if (movimiento.fechaSalida.isNotEmpty)
                                Text('Fecha Salida: ${movimiento.fechaSalida}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddEditMovimientoScreen(
                                            movimiento: movimiento,
                                            isEditing: true,
                                          ),
                                    ),
                                  ).then((_) => _refreshMovimientos());
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _showDeleteDialog(movimiento.id),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MovimientoDetailScreen(
                                      movimiento: movimiento,
                                    ),
                              ),
                            ).then((_) => _refreshMovimientos());
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'scan_qr',
            backgroundColor: Colors.green,
            onPressed: _scanQRCode,
            child: const Icon(Icons.qr_code_scanner, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_movement',
            backgroundColor: Colors.indigo,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const AddEditMovimientoScreen(isEditing: false),
                ),
              ).then((_) => _refreshMovimientos());
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este movimiento?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMovimiento(id);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AddEditMovimientoScreen extends StatefulWidget {
  final Movimiento? movimiento;
  final bool isEditing;
  final Map<String, dynamic>? initialData;

  const AddEditMovimientoScreen({
    super.key,
    this.movimiento,
    required this.isEditing,
    this.initialData,
  });

  @override
  State<AddEditMovimientoScreen> createState() =>
      _AddEditMovimientoScreenState();
}

class _AddEditMovimientoScreenState extends State<AddEditMovimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _documentoPersonaController;
  late TextEditingController _serialEquipoController;
  late TextEditingController _centroFormacionController;
  late TextEditingController _tipoIngresoController;
  late TextEditingController _tipoSalidaController;
  late TextEditingController _fechaIngresoController;
  late TextEditingController _fechaSalidaController;

  @override
  void initState() {
    super.initState();

    // Usar datos iniciales si están presentes, de lo contrario usar datos del movimiento
    final initialData =
        widget.initialData ??
        {
          'documentoPersona': widget.movimiento?.documentoPersona ?? '',
          'serialEquipo': widget.movimiento?.serialEquipo ?? '',
          'centroFormacion': widget.movimiento?.centroFormacion ?? 'CESGE',
          'tipoIngreso': widget.movimiento?.tipoIngreso ?? 'Permanente',
          'tipoSalida': widget.movimiento?.tipoSalida ?? '',
          'fechaIngreso':
              widget.movimiento?.fechaIngreso ?? DateTime.now().toString(),
          'fechaSalida': widget.movimiento?.fechaSalida ?? '',
        };

    _documentoPersonaController = TextEditingController(
      text: initialData['documentoPersona'],
    );
    _serialEquipoController = TextEditingController(
      text: initialData['serialEquipo'],
    );
    _centroFormacionController = TextEditingController(
      text: initialData['centroFormacion'],
    );
    _tipoIngresoController = TextEditingController(
      text: initialData['tipoIngreso'],
    );
    _tipoSalidaController = TextEditingController(
      text: initialData['tipoSalida'],
    );
    _fechaIngresoController = TextEditingController(
      text: initialData['fechaIngreso'],
    );
    _fechaSalidaController = TextEditingController(
      text: initialData['fechaSalida'],
    );
  }

  @override
  void dispose() {
    _documentoPersonaController.dispose();
    _serialEquipoController.dispose();
    _centroFormacionController.dispose();
    _tipoIngresoController.dispose();
    _tipoSalidaController.dispose();
    _fechaIngresoController.dispose();
    _fechaSalidaController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Formatear fechas correctamente
        final fechaIngreso =
            _fechaIngresoController.text.isEmpty
                ? DateTime.now().toString()
                : _fechaIngresoController.text;

        final movimientoData =
            widget.isEditing
                ? {
                  'tipoSalida': _tipoSalidaController.text,
                  'fechaSalida': _fechaSalidaController.text,
                }
                : {
                  'documentoPersona': _documentoPersonaController.text,
                  'serialEquipo': _serialEquipoController.text,
                  'centroFormacion': _centroFormacionController.text,
                  'tipoIngreso': _tipoIngresoController.text,
                  'fechaIngreso': fechaIngreso,
                };

        final url = Uri.parse(
          widget.isEditing
              ? 'http://127.0.0.1:5000/movimiento/${widget.movimiento?.id}'
              : 'http://127.0.0.1:5000/movimiento',
        );

        print('Enviando datos: ${movimientoData}'); // Debug

        final response =
            widget.isEditing
                ? await http.put(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(movimientoData),
                )
                : await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(movimientoData),
                );

        print('Respuesta: ${response.statusCode} - ${response.body}'); // Debug

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEditing
                    ? 'Movimiento actualizado correctamente'
                    : 'Movimiento creado correctamente',
              ),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al guardar: ${response.statusCode} - ${response.body}',
              ),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Editar Movimiento' : 'Agregar Movimiento',
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _documentoPersonaController,
                decoration: const InputDecoration(
                  labelText: 'Documento Persona',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el documento de la persona';
                  }
                  return null;
                },
                readOnly: widget.isEditing,
              ),
              TextFormField(
                controller: _serialEquipoController,
                decoration: const InputDecoration(labelText: 'Serial Equipo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el serial del equipo';
                  }
                  return null;
                },
                readOnly: widget.isEditing,
              ),
              TextFormField(
                controller: _centroFormacionController,
                decoration: const InputDecoration(
                  labelText: 'Centro de Formación',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el centro de formación';
                  }
                  return null;
                },
                readOnly: widget.isEditing,
              ),
              TextFormField(
                controller: _tipoIngresoController,
                decoration: const InputDecoration(labelText: 'Tipo de Ingreso'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el tipo de ingreso';
                  }
                  return null;
                },
                readOnly: widget.isEditing,
              ),
              TextFormField(
                controller: _tipoSalidaController,
                decoration: const InputDecoration(labelText: 'Tipo de Salida'),
                validator:
                    widget.isEditing
                        ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el tipo de salida';
                          }
                          return null;
                        }
                        : null,
                readOnly: !widget.isEditing,
              ),
              TextFormField(
                controller: _fechaIngresoController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Ingreso',
                ),
                onTap:
                    widget.isEditing
                        ? null
                        : () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            _fechaIngresoController.text =
                                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                          }
                        },
                readOnly: true,
              ),
              TextFormField(
                controller: _fechaSalidaController,
                decoration: const InputDecoration(labelText: 'Fecha de Salida'),
                onTap:
                    widget.isEditing
                        ? () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            _fechaSalidaController.text =
                                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                          }
                        }
                        : null,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _submitForm,
                child: Text(
                  widget.isEditing ? 'Actualizar' : 'Guardar',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovimientoDetailScreen extends StatelessWidget {
  final Movimiento movimiento;

  const MovimientoDetailScreen({super.key, required this.movimiento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movimiento ${movimiento.id}'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${movimiento.id}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Documento Persona: ${movimiento.documentoPersona}'),
            const SizedBox(height: 10),
            Text('Serial Equipo: ${movimiento.serialEquipo}'),
            const SizedBox(height: 10),
            Text('Centro Formación: ${movimiento.centroFormacion}'),
            const SizedBox(height: 10),
            Text('Tipo Ingreso: ${movimiento.tipoIngreso}'),
            const SizedBox(height: 10),
            Text('Tipo Salida: ${movimiento.tipoSalida}'),
            const SizedBox(height: 10),
            Text('Fecha Ingreso: ${movimiento.fechaIngreso}'),
            const SizedBox(height: 10),
            Text('Fecha Salida: ${movimiento.fechaSalida}'),
          ],
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController cameraController;
  bool _torchEnabled = false;
  CameraFacing _cameraFacing = CameraFacing.back;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      torchEnabled: _torchEnabled,
      facing: _cameraFacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        actions: [
          // Botón para alternar el flash
          IconButton(
            icon: Icon(
              _torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: _torchEnabled ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _torchEnabled = !_torchEnabled;
                cameraController.toggleTorch();
              });
            },
          ),
          // Botón para cambiar de cámara
          IconButton(
            icon: Icon(
              _cameraFacing == CameraFacing.front 
                ? Icons.camera_front 
                : Icons.camera_rear,
            ),
            onPressed: () {
              setState(() {
                _cameraFacing = _cameraFacing == CameraFacing.front 
                  ? CameraFacing.back 
                  : CameraFacing.front;
                cameraController.switchCamera();
              });
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              Navigator.pop(context, barcode.rawValue);
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

extension on MobileScannerController {
  get cameraFacing => null;
}
