import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';

class Persona {
  final String documento;
  final String tipoDocumento;
  final String nombre;
  final String apellido;
  final int tipoPersonaId;
  final String equipo;
  final String fechaRegistro;
  final int estado;

  Persona({
    required this.documento,
    required this.tipoDocumento,
    required this.nombre,
    required this.apellido,
    required this.tipoPersonaId,
    required this.equipo,
    required this.fechaRegistro,
    required this.estado,
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      documento: json['documento'] ?? '',
      tipoDocumento: json['tipoDocumento'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      tipoPersonaId: json['tipoPersonaId'] ?? 0,
      equipo: json['equipo'] ?? '',
      fechaRegistro: json['fechaRegistro'] ?? '',
      estado: json['estado'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documento': documento,
      'tipoDocumento': tipoDocumento,
      'nombre': nombre,
      'apellido': apellido,
      'tipoPersonaId': tipoPersonaId,
      'equipo': equipo,
      'fechaRegistro': fechaRegistro,
      'estado': estado,
    };
  }
}

class PersonaListScreen extends StatefulWidget {
  const PersonaListScreen({super.key});

  @override
  State<PersonaListScreen> createState() => _PersonaListScreenState();
}

class _PersonaListScreenState extends State<PersonaListScreen> {
  late Future<List<Persona>> futurePersonas;
  final String apiUrl = 'http://127.0.0.1:5000/persona';
  List<Persona> personasList = [];
  List<Persona> filteredPersonas = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futurePersonas = _fetchPersonas();
    searchController.addListener(_filterPersonas);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<Persona>> _fetchPersonas() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        personasList =
            (data['personas'] as List).map((e) => Persona.fromJson(e)).toList();
        filteredPersonas = List.from(personasList);
        return personasList;
      } else {
        throw Exception('Failed to load personas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load personas: $e');
    }
  }

  void _filterPersonas() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredPersonas =
          personasList.where((persona) {
            return persona.documento.toLowerCase().contains(query) ||
                persona.nombre.toLowerCase().contains(query) ||
                persona.apellido.toLowerCase().contains(query);
          }).toList();
    });
  }

  Future<void> _deletePersona(String documento) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$documento'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _refreshPersonas();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Persona eliminada correctamente')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar persona: ${response.body}'),
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

  Future<void> _toggleEstado(String documento, int currentEstado) async {
    try {
      final newEstado = currentEstado == 1 ? 0 : 1;
      final response = await http.put(
        Uri.parse('$apiUrl/$documento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'estado': newEstado}),
      );

      if (response.statusCode == 200) {
        _refreshPersonas();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Estado cambiado a ${newEstado == 1 ? 'Activo' : 'Inactivo'}',
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _refreshPersonas() {
    setState(() {
      futurePersonas = _fetchPersonas();
    });
  }

  void _showQrDialog(Persona persona) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              minWidth: 300,
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Código QR para ${persona.nombre}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: QrImageView(
                    data:
                        'Documento: ${persona.documento}\nEquipo: ${persona.equipo}',
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Documento: ${persona.documento}'),
                const SizedBox(height: 8),
                Text('Equipo: ${persona.equipo}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBarcodeDialog(Persona persona) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              minWidth: 300,
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Código de Barras para ${persona.nombre}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: 'Documento: ${persona.documento}\nEquipo: ${persona.equipo}',
                    width: 200,
                    height: 100,
                    drawText: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Documento: ${persona.documento}'),
                const SizedBox(height: 8),
                Text('Equipo: ${persona.equipo}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Personas'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPersonas,
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
                labelText: 'Buscar personas',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Persona>>(
              future: futurePersonas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || filteredPersonas.isEmpty) {
                  return const Center(
                    child: Text('No hay personas registradas'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: filteredPersonas.length,
                    itemBuilder: (context, index) {
                      final persona = filteredPersonas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          title: Text('${persona.nombre} ${persona.apellido}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Documento: ${persona.documento}'),
                              Text('Tipo Persona: ${persona.tipoPersonaId}'),
                              Text('Equipo: ${persona.equipo}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.qr_code,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showQrDialog(persona),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.barcode_reader,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showBarcodeDialog(persona),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.toggle_on,
                                  color:
                                      persona.estado == 1
                                          ? Colors.green
                                          : Colors.red,
                                  size: 30,
                                ),
                                onPressed:
                                    () => _toggleEstado(
                                      persona.documento,
                                      persona.estado,
                                    ),
                              ),
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
                                          (context) => AddEditPersonaScreen(
                                            persona: persona,
                                            isEditing: true,
                                          ),
                                    ),
                                  ).then((_) => _refreshPersonas());
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _showDeleteDialog(persona.documento),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        PersonaDetailScreen(persona: persona),
                              ),
                            ).then((_) => _refreshPersonas());
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const AddEditPersonaScreen(isEditing: false),
            ),
          ).then((_) => _refreshPersonas());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(String documento) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar esta persona?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePersona(documento);
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

class AddEditPersonaScreen extends StatefulWidget {
  final Persona? persona;
  final bool isEditing;

  const AddEditPersonaScreen({
    super.key,
    this.persona,
    required this.isEditing,
  });

  @override
  State<AddEditPersonaScreen> createState() => _AddEditPersonaScreenState();
}

class _AddEditPersonaScreenState extends State<AddEditPersonaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _documentoController;
  late TextEditingController _tipoDocumentoController;
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _tipoPersonaIdController;
  late TextEditingController _equipoController;
  late TextEditingController _fechaRegistroController;
  late int _estado;

  @override
  void initState() {
    super.initState();
    _documentoController = TextEditingController(
      text: widget.persona?.documento ?? '',
    );
    _tipoDocumentoController = TextEditingController(
      text: widget.persona?.tipoDocumento ?? '',
    );
    _nombreController = TextEditingController(
      text: widget.persona?.nombre ?? '',
    );
    _apellidoController = TextEditingController(
      text: widget.persona?.apellido ?? '',
    );
    _tipoPersonaIdController = TextEditingController(
      text: widget.persona?.tipoPersonaId.toString() ?? '',
    );
    _equipoController = TextEditingController(
      text: widget.persona?.equipo ?? '',
    );
    _fechaRegistroController = TextEditingController(
      text: widget.persona?.fechaRegistro ?? '',
    );
    _estado = widget.persona?.estado ?? 1;
  }

  @override
  void dispose() {
    _documentoController.dispose();
    _tipoDocumentoController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _tipoPersonaIdController.dispose();
    _equipoController.dispose();
    _fechaRegistroController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final persona = {
          'documento': _documentoController.text,
          'tipoDocumento': _tipoDocumentoController.text,
          'nombre': _nombreController.text,
          'apellido': _apellidoController.text,
          'tipoPersonaId': int.parse(_tipoPersonaIdController.text),
          'equipo': _equipoController.text,
          'fechaRegistro': _fechaRegistroController.text,
          'estado': _estado,
        };

        final url = Uri.parse(
          widget.isEditing
              ? 'http://127.0.0.1:5000/persona/${_documentoController.text}'
              : 'http://127.0.0.1:5000/persona',
        );

        final response =
            widget.isEditing
                ? await http.put(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(persona),
                )
                : await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(persona),
                );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEditing
                    ? 'Persona actualizada correctamente'
                    : 'Persona creada correctamente',
              ),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar persona: ${response.body}'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Persona' : 'Agregar Persona'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _documentoController,
                decoration: const InputDecoration(labelText: 'Documento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el documento';
                  }
                  return null;
                },
                readOnly: widget.isEditing,
              ),
              TextFormField(
                controller: _tipoDocumentoController,
                decoration: const InputDecoration(labelText: 'Tipo Documento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el tipo de documento';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el apellido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tipoPersonaIdController,
                decoration: const InputDecoration(labelText: 'Tipo Persona ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el tipo de persona';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _equipoController,
                decoration: const InputDecoration(labelText: 'Equipo'),
              ),
              TextFormField(
                controller: _fechaRegistroController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Registro',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _fechaRegistroController.text =
                        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Estado'),
                subtitle: Text(_estado == 1 ? 'Activo' : 'Inactivo'),
                value: _estado == 1,
                onChanged: (value) {
                  setState(() {
                    _estado = value ? 1 : 0;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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

class PersonaDetailScreen extends StatelessWidget {
  final Persona persona;

  const PersonaDetailScreen({super.key, required this.persona});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${persona.nombre} ${persona.apellido}'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Código QR para ${persona.nombre}'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        QrImageView(
                          data:
                              'Documento: ${persona.documento}\nEquipo: ${persona.equipo}',
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        const SizedBox(height: 10),
                        Text('Documento: ${persona.documento}'),
                        Text('Equipo: ${persona.equipo}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.barcode_reader),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Código de Barras para ${persona.nombre}'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: 'Documento: ${persona.documento}\nEquipo: ${persona.equipo}',
                          width: 200,
                          height: 100,
                          drawText: true,
                        ),
                        const SizedBox(height: 10),
                        Text('Documento: ${persona.documento}'),
                        Text('Equipo: ${persona.equipo}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documento: ${persona.documento}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text('Tipo Documento: ${persona.tipoDocumento}'),
            const SizedBox(height: 10),
            Text('Nombre: ${persona.nombre}'),
            const SizedBox(height: 10),
            Text('Apellido: ${persona.apellido}'),
            const SizedBox(height: 10),
            Text('Tipo Persona ID: ${persona.tipoPersonaId}'),
            const SizedBox(height: 10),
            Text('Equipo: ${persona.equipo}'),
            const SizedBox(height: 10),
            Text('Fecha Registro: ${persona.fechaRegistro}'),
            const SizedBox(height: 10),
            Chip(
              label: Text(
                persona.estado == 1 ? 'Activo' : 'Inactivo',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: persona.estado == 1 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}